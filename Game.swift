//
//  Game.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 22/04/16.
//
//

import Foundation
import SpriteKit
import GameplayKit

class Game : NSObject {
    static let sharedInstance = Game()
    
    // Control systems for the player, computer and generic state machine (e.g.: tiles are not 
    //  'played' by the CPU, but can still have several states - some tiles can be destroyed).
    fileprivate let cpuControlSystem = ComponentSystem(componentClass: CpuControlComponent.self)
    fileprivate let playerControlSystem = ComponentSystem(componentClass: PlayerControlComponent.self)
    fileprivate let stateMachineSystem = ComponentSystem(componentClass: StateMachineComponent.self)
    
    // The current level. After the level is assigned, we add all entities of the level to the 
    //  entity lists of the game.
    fileprivate var level: Level? = nil
    
    fileprivate var isLevelCompleted = false
    
    // Enrage timer for monsters.
    fileprivate var timeRemaining: TimeInterval = 0
    fileprivate var extraGameTime: TimeInterval = TimeInterval.nan
    fileprivate var timeExpired = false
    fileprivate var hurryUpShown = false
    
    fileprivate(set) var gameScene: GameScene? = nil
    
    fileprivate(set) var monsterForAlienMap = [String: Creature]()
    
    // List of entities currently active in the game. These lists are updated each game loop.
    fileprivate(set) var creatures = [Creature]()
    fileprivate(set) var props = [Entity]()
    fileprivate(set) var bombs = [Bomb]()
    fileprivate(set) var explosions = [Explosion]()
    fileprivate(set) var tiles = [Tile]()
    fileprivate(set) var projectiles = [Projectile]()
    fileprivate(set) var points = [Points]()
    fileprivate(set) var powerUps = [PowerUp]()
    fileprivate(set) var coins = [Coin]()
    
    // Players are referenced from the creatures array as it contains both players and monsters.
    fileprivate(set) weak var player1: Player?
    fileprivate(set) weak var player2: Player?
    
    // Lists of entities to be added or removed in the next update.
    fileprivate var entitiesToAdd = [Entity]()
    fileprivate var entitiesToRemove = [Entity]()
    
    fileprivate var creatureLoader: CreatureLoader?
    
    override init() {
        super.init()
        
        creatureLoader = CreatureLoader(forGame: self)
    }
    
    func configureForGameScene(_ gameScene: GameScene) {
        self.level = gameScene.level
        self.gameScene = gameScene
        self.gameScene?.physicsWorld.contactDelegate = self
    }
        
    func handlePlayerDidStartAction(_ player: PlayerIndex, action: PlayerAction) {
        switch player {
        case .player1:
            if let playerControlComponent = level?.player1?.component(ofType: PlayerControlComponent.self) {
                playerControlComponent.addAction(action)
            }
        case .player2:
            if let playerControlComponent = level?.player2?.component(ofType: PlayerControlComponent.self) {
                playerControlComponent.addAction(action)
            }
        }
    }
    
    func handlePlayerDidStopAction(_ player: PlayerIndex, action: PlayerAction) {
        switch player {
        case .player1:
            if let playerControlComponent = level?.player1?.component(ofType: PlayerControlComponent.self) {
                playerControlComponent.removeAction(action)
            }
        case .player2:
            if let playerControlComponent = level?.player2?.component(ofType: PlayerControlComponent.self) {
                playerControlComponent.removeAction(action)
            }
        }
    }
    
    // The main update loop. Called every frame to update game state.
    func update(_ deltaTime: CFTimeInterval) {
        // Add new entities (e.g. dropped bombs) and remove destroyed entities (e.g. killed monsters)
        updateEntityLists()
        
        // when all players are dead or monsters are dead, finish game appropriately.
        let playerAlive = isPlayerAlive()
        let monsterAlive = isMonsterAlive()
        
        let win = playerAlive && !monsterAlive
        let loss = monsterAlive && !playerAlive
        
        // TODO: It's ugly that finishLevel() is both called after cheer state and in case of loss.
        //  If we call finishLevel() on both win and loss, it should be clear here. Perhaps cheer
        //  should be called in some other, indirect way (e.g.: when player is not moving, cheer 
        //  if level is finished.
        if win {
            if isLevelCompleted == false {
                player1?.cheer()
                player2?.cheer()
            }
        } else if loss {
            finishLevel(false)
        }
        
        timeRemaining -= deltaTime
        
        if extraGameTime.isNaN == false {
            extraGameTime -= deltaTime
            
            if extraGameTime <= 0 {
                replaceAliensWithMonsters()
                extraGameTime = TimeInterval.nan
            }
        }
        
        // Update player movement, monster movement, state machines ...
        updateComponentSystems(deltaTime)
        
        player1?.update(deltaTime: deltaTime)
        player2?.update(deltaTime: deltaTime)
        powerUps.forEach({ $0.update(deltaTime: deltaTime) })
        
        // Enrage timer. When timer is expired, monsters become more dangerous.
        if timeRemaining > 0 && !isLevelCompleted {
            gameScene?.updateTimeRemaining(timeRemaining)
            
            if timeRemaining < 30 && hurryUpShown == false {
                hurryUpShown = true
                
                let play = SKAction.playSoundFileNamed("HurryUp.caf", waitForCompletion: false)
                gameScene?.run(play)
            }
        } else if !timeExpired {
            timeExpired = true
            enrageMonsters()
        }
    }
    
    func configureLevel() {
        removeAllEntities()
        
        gameScene?.world.removeAllChildren()
        isLevelCompleted = false

        if let level = self.level {
            for x in 0 ..< level.width {
                for y in 0 ..< level.height {
                    let gridPosition = Point(x: x, y: y)
                    if let tile = level.tileAtGridPosition(gridPosition) {
                        addEntity(tile)
                    }
                    
                    if let prop = level.propAtGridPosition(gridPosition) {
                        addEntity(prop)
                    }
                    
                    if let creature = level.creatureAtGridPosition(gridPosition) {
                        addEntity(creature)
                    }
                    
                    if let coin = level.coinAtGridPosition(gridPosition) {
                        addEntity(coin)
                    }
                    
                    // NOTE: We don't parse powers here, instead power entites are added when tiles 
                    //  are destroyed. The reason for this is that powers need to self-destruct 
                    //  after a set amount of time and self destruct is triggered after spawn state.
                }
            }

            timeRemaining = level.timer
        }
        
        playMusic()
    }
    
    func nextVisibleGridPositionFromGridPosition(_ gridPosition: Point, inDirection direction: Direction) -> Point? {
        var nextGridPosition: Point?
        
        switch direction {
        case .up: nextGridPosition = Point(x: gridPosition.x, y: gridPosition.y + 1)
        case .down: nextGridPosition = Point(x: gridPosition.x, y: gridPosition.y - 1)
        case .left: nextGridPosition = Point(x: gridPosition.x - 1, y: gridPosition.y)
        case .right: nextGridPosition = Point(x: gridPosition.x + 1, y: gridPosition.y)
        default: break
        }
    
        if nextGridPosition != nil {
            if tileAtGridPosition(nextGridPosition!) != nil {
                nextGridPosition = nil
            }
        }
        
        return nextGridPosition
    }
    
    func visibleGridPositionsFromGridPosition(_ gridPosition: Point, inDirection direction: Direction) -> [Point] {
        var gridPositions = [Point]()
        
        switch direction {
        case .up:
            for y in gridPosition.y ..< level!.height {
                gridPositions.append(Point(x: gridPosition.x, y: y))
            }
        case .down:
            for y in (0 ..< gridPosition.y).reversed() {
                gridPositions.append(Point(x: gridPosition.x, y: y))
            }
        case .left:
            for x in (0 ..< gridPosition.x).reversed() {
                gridPositions.append(Point(x: x, y: gridPosition.y))
            }
        case .right:
            for x in (gridPosition.x ..< level!.width) {
                gridPositions.append(Point(x: x, y: gridPosition.y))
            }
        default: break
        }
        
        for (index, gridPosition) in gridPositions.enumerated() where tileAtGridPosition(gridPosition) != nil {
            gridPositions.removeSubrange(index ..< gridPositions.count)
            break
        }
        
        return gridPositions
    }
    
    // MARK: - Private
    
    fileprivate func playMusic() {
        if let level = self.level {
            // TODO: Music improvements.
            //  1. Compare songs in music player - don't play if same song.
            //  2. Music setting should initially return true (first load of app)
            let musicEnabled = Settings.musicEnabled()
            if musicEnabled && MusicPlayer.sharedInstance.isPlaying == false {
                if let music = level.music {
                    do {
                        try MusicPlayer.sharedInstance.playMusic(music)
                    } catch let error {
                        // TODO: Proper error handling
                        print(error)
                    }
                } else {
                    updateInfoOverlayWithMessage("no music configured for level")
                }
            } else {
                MusicPlayer.sharedInstance.stop()
            }
        }
    }
    
    fileprivate func enrageMonsters() {
        creatures
            .filter({ $0 is Monster })
            .forEach({
                if let visualComponent = $0.component(ofType: VisualComponent.self) {
                    visualComponent.spriteNode.speed *= 1.6
                }
            })
    }
    
    fileprivate func updateHudForPlayer(_ player: Player) {
        gameScene?.updateHudForPlayer(player)
    }
    
    fileprivate func updateComponentSystems(_ deltaTime: TimeInterval) {
        cpuControlSystem.update(deltaTime: deltaTime)
        playerControlSystem.update(deltaTime: deltaTime)
        stateMachineSystem.update(deltaTime: deltaTime)
    }
    
    fileprivate func updateEntityLists() {
        for entity in self.entitiesToRemove {
            switch entity {
            case is Explosion: explosions.remove(entity as! Explosion)
            case is Bomb: bombs.remove(entity as! Bomb)
            case is Tile: tiles.remove(entity as! Tile)
            case is Creature: creatures.remove(entity as! Creature)
            case is Projectile: projectiles.remove(entity as! Projectile)
            case is Coin: coins.remove(entity as! Coin)
            case is Prop: props.remove(entity as! Prop)
            case is Points: points.remove(entity as! Points)
            case is PowerUp: powerUps.remove(entity as! PowerUp)
            default: print("unhandled entity type for instance: \(entity)")
            }
            
            if let visualComponent = entity.component(ofType: VisualComponent.self) {
                visualComponent.spriteNode.removeFromParent()
            }
            
            playerControlSystem.removeComponent(foundIn: entity)
            cpuControlSystem.removeComponent(foundIn: entity)
            stateMachineSystem.removeComponent(foundIn: entity)
        }
        entitiesToRemove.removeAll()
        
        for entity in entitiesToAdd {
            entity.delegate = self
            
            switch entity {
            case is Bomb: bombs.append(entity as! Bomb)
            case is Explosion: explosions.append(entity as! Explosion)
            case is Tile: tiles.append(entity as! Tile)
            case is Creature: creatures.append(entity as! Creature)
            case is Projectile: projectiles.append(entity as! Projectile)
            case is Coin: coins.append(entity as! Coin)
            case is Prop: props.append(entity as! Prop)
            case is Points: points.append(entity as! Points)
            case is PowerUp: powerUps.append(entity as! PowerUp)
            default: print("unhandled entity type for instance: \(entity)")
            }
            
            print("ADD: \(entity)")
            
            if let visualComponent = entity.component(ofType: VisualComponent.self) {
                // Only calculate a position based on gridPosition if no position is already set.
                if visualComponent.spriteNode.position.equalTo(CGPoint.zero) {
                    visualComponent.spriteNode.position = positionForGridPosition(entity.gridPosition)
                }
                
                gameScene?.world.addChild(visualComponent.spriteNode)
            }
            
            playerControlSystem.addComponent(foundIn: entity)
            cpuControlSystem.addComponent(foundIn: entity)
            stateMachineSystem.addComponent(foundIn: entity)
        }
        entitiesToAdd.removeAll()
    }
    
    fileprivate func finishLevel(_ didPlayerWin: Bool) {
        if isLevelCompleted == false {
            isLevelCompleted = true
            
            let delay = 2.0
            
            MusicPlayer.sharedInstance.fadeOut(delay)

            let wait = SKAction.wait(forDuration: delay)
            let soundFile = didPlayerWin ? "CompleteLevel.caf" : "GameOver.caf"
            let play = SKAction.playSoundFileNamed(soundFile, waitForCompletion: false)
            let sequence = SKAction.sequence([wait, play, wait]);
            
            gameScene?.run(sequence, completion: {
                // TODO: Maybe remove, since during 'configure' (level loading) we remove all 
                //  entities anyway.
                self.removeAllEntities()
                self.gameScene!.levelFinished(self.level!)            
            })
        }
    }

    fileprivate func isMonsterAlive() -> Bool {
        var isMonsterAlive = false
        
        for creature in creatures where creature.isKind(of: Monster.self) {
            isMonsterAlive = true
            break
        }
        
        return isMonsterAlive
    }
    
    fileprivate func isPlayerAlive() -> Bool {
        let players = [player1, player2].flatMap{ $0 }.filter{ $0.lives >= 0 }
        return players.count > 0
    }
    
    fileprivate func removeAllEntities() {
        entitiesToAdd.removeAll()
        entitiesToRemove.removeAll()
        
        creatures.removeAll()
        props.removeAll()
        bombs.removeAll()
        explosions.removeAll()
        tiles.removeAll()
        projectiles.removeAll()
        points.removeAll()
        powerUps.removeAll()
        coins.removeAll()
        
        stateMachineSystem.removeAllComponents()
        cpuControlSystem.removeAllComponents()
        playerControlSystem.removeAllComponents()
    }
    
    fileprivate func replaceMonstersWithAliens() {
        let monsters = creatures.filter({ (creature) -> Bool in
            return creature is Monster && creature.isDestroyed == false
        })
        
        for monster in monsters {
            do {
                if let alien = try creatureLoader!.monsterWithName("Alien", gridPosition: monster.gridPosition) {
                    monsterForAlienMap[alien.uuid] = monster
                    
                    if let monsterVc = monster.component(ofType: VisualComponent.self), let alienVc = alien.component(ofType: VisualComponent.self) {
                        alienVc.spriteNode.position = monsterVc.spriteNode.position
                    }

                    addEntity(alien)
                    removeEntity(monster)
                }
            } catch let error {
                updateInfoOverlayWithMessage("\(error)")
            }
        }

        extraGameTime = 10
    }
    
    fileprivate func replaceAliensWithMonsters() {
        let aliens = creatures.filter({ (creature) -> Bool in
            return creature is Monster && creature.isDestroyed == false
        })

        for alien in aliens {
            if let monster = monsterForAlienMap[alien.uuid],
                let name = monster.name {
                
                do {
                    if let monster = try creatureLoader!.monsterWithName(name, gridPosition: alien.gridPosition) {
                        addEntity(monster)
                    }
                } catch let error {
                    updateInfoOverlayWithMessage("\(error)")
                }

                removeEntity(alien)
            }
        }
        
        monsterForAlienMap.removeAll()
    }

    // MARK: - Private (Collision Handling)
    
    fileprivate func handleContactBetweenExplosion(_ explosion: Explosion, andCreature creature: Creature) {
        creature.destroy()
    }
    
    fileprivate func handleContactBetweenProjectile(_ projectile: Projectile, andEntity entity: GKEntity) {
        // TODO: convert GKEntity to Entity
        
        projectile.destroy()
        
        if let player = entity as? Player, player.isDestroyed == false {
            player.hit(projectile.damage)
        }
    }
    
    fileprivate func handleContactBetweenProp(_ prop: Prop, andPlayer player: Player) {
        prop.destroy()
        
        let coinsInLevel = coins.filter { (coin) -> Bool in
            coin.isDestroyed == false
        }
        
        if coinsInLevel.count == 0 && timeRemaining > 0 {
            replaceMonstersWithAliens()
        }
    }
    
    fileprivate func handleContactBetweenMonster(_ monster: Monster, andMonster otherMonster: Monster) {
        monster.stop()
        otherMonster.stop()
    }
    
    fileprivate func handleContactBetweenMonster(_ monster: Monster, andPlayer player: Player) {
        _ = player.moveInDirection(.none)
    }
    
    fileprivate func handleContactBetweenPowerUp(_ powerUp: PowerUp, andPlayer player: Player) {
        powerUp.hit()
        
        if powerUp.activated == false {
            powerUp.activate(forPlayer: player)
            updateHudForPlayer(player)
        }
    }
    
    // MARK: - Public
    
    func addEntity(_ entity: Entity) {
        entitiesToAdd.append(entity)
        
        switch entity {
        case let tile as Tile:
            // TODO (workaround): because tile loading uses different path compared to entity
            //  loading and we still need to add a state machine.
            if tile.tileType == .destructableBlock {
                let stateMachineComponent = StateMachineComponent(game: self, entity: tile, states: [SpawnState(), DestroyState()])
                tile.addComponent(stateMachineComponent)
            }
        case let player as Player:
            switch player.index {
            case .player1: player1 = player
            case .player2: player2 = player
            }
        
            updateHudForPlayer(player)
        default: break
        }
    }
    
    func removeEntity(_ entity: Entity) {
        entitiesToRemove.append(entity)
    }
    
    func bombCountForPlayer(_ player: PlayerIndex) -> Int {
        let count = bombs.filter { $0.player == player }.count
        return count
    }
    
    func resume() {
        if Settings.musicEnabled() {
            MusicPlayer.sharedInstance.resume()
        } else {            
            MusicPlayer.sharedInstance.stop()
        }
    }
    
    // MARK: - Public (Entity Search) 
    
    func playerAtGridPosition(_ gridPosition: Point) -> Player? {
        var entity: Player?
        
        let players = [player1, player2].flatMap{ $0 }
        
        for player in players where pointEqualToPoint(player.gridPosition, gridPosition) {
            entity = player
            break
        }
        
        return entity
    }
    
    func bombAtGridPosition(_ gridPosition: Point) -> Bomb? {
        var entity: Bomb?
        
        for bomb in bombs where pointEqualToPoint(bomb.gridPosition, gridPosition) {
            entity = bomb
            break
        }
        
        return entity
    }
    
    func creatureAtGridPosition(_ gridPosition: Point) -> Creature? {
        var entity: Creature? = nil
        
        for creature in creatures {
            if let visualComponent = creature.component(ofType: VisualComponent.self) {
                // We don't use the creature grid position property directly, since it's not
                //  updated until a creature finishes walking to a node. Instead we translate
                //  the creatures' sprite position to a grid position.
                let position = visualComponent.spriteNode.position
                let creatureGridPosition = gridPositionForPosition(position)
                
                if pointEqualToPoint(creatureGridPosition, gridPosition) {
                    entity = creature
                }
            }
        }
        
        return entity
    }
    
    func tileAtGridPosition(_ gridPosition: Point) -> Tile? {
        var entity: Tile? = nil
        
        for tile in tiles where pointEqualToPoint(tile.gridPosition, gridPosition) {
            entity = tile
            break
        }
        
        return entity
    }
    
    func bossAtGridPosition(_ gridPosition: Point) -> Monster? {
        var boss: Monster? = nil
        
        for creature in creatures {
            guard
                let monster = creature as? Monster,
                let configComponent = monster.component(ofType: ConfigComponent.self), configComponent.creatureType == .boss else { return nil }
            
            let wuSize = configComponent.wuSize
            let xOffset = (wuSize.width - 1) / 2
            let yOffset = (wuSize.height - 1) / 2
            
            let position = monster.gridPosition
            let xRange = position.x - xOffset ... position.x + xOffset
            let yRange = position.y - yOffset ... position.y + yOffset
            
            if xRange.contains(gridPosition.x) && yRange.contains(gridPosition.y) {
                boss = monster
            }
        }
        
        return boss
    }
    
    func powerAtGridPosition(_ gridPosition: Point) -> PowerUp? {
        var entity: PowerUp? = nil
        
        for powerUp in powerUps where pointEqualToPoint(powerUp.gridPosition, gridPosition) {
            entity = powerUp
            break
        }
        
        return entity
    }
}

// MARK: - EntityDelegate

extension Game : EntityDelegate {
    func entityWillDestroy(_ entity: Entity) {
        switch entity {
        case let bomb as Bomb:
            do {
                try bomb.explodeAtGridPosition(entity.gridPosition)
            } catch let error {
                print("error: \(error)")
            }
//            TODO: Currently performance implications of shake are unclear for tvOS.
//              let shake = SKAction.shake(self.gameScene!.world.position, duration: 0.5)
//              self.gameScene?.world.runAction(shake)
        case is Tile:
            if let power = level?.powerUpAtGridPosition(entity.gridPosition) {
                addEntity(power)
            }
        default: break
        }
                
        if let value = entity.value {
            let propLoader = PropLoader(forGame: Game.sharedInstance)
            let points = (try! propLoader.pointsWithType(value, gridPosition: entity.gridPosition))!
            Game.sharedInstance.addEntity(points)
        }
    }
    
    func entityDidCheer(_ entity: Entity) {
        finishLevel(true)
        
        if let player = entity as? Player {
            player.control()
        }
    }
    
    func entityDidDecay(_ entity: Entity) {
        switch entity {
        case is Bomb: fallthrough
        case is PowerUp:
            entity.destroy()
        default: break
        }
    }
    
    func entityDidDestroy(_ entity: Entity) {
        switch entity {
        case let player as Player:
            updateHudForPlayer(player)
            player.spawn()
            
            if player.lives < 0 {
                removeEntity(entity)
            }
        case let creature as Creature where creature.lives < 0:
            removeEntity(entity)
            
            // If an alien is killed, remove the related monster.
            if let monster = monsterForAlienMap[entity.uuid] {
                removeEntity(monster)
            }
        case is Bomb: fallthrough
        case is Tile: fallthrough
        default:
            removeEntity(entity)
        }
    }
    
    func entityDidHit(_ entity: Entity) {
        switch entity {
        case let player as Player:
            if !player.isDestroyed {
                player.control()
            }
            updateHudForPlayer(player)
        case is Projectile: fallthrough
        case is PowerUp:
            entity.destroy()
        default: break
        }
    }
    
    func entityDidFloat(_ entity: Entity) {
        switch entity {
        case is Points: entity.destroy()
        default: break
        }
    }
    
    func entityDidSpawn(_ entity: Entity) {
        switch entity {
        case is Bomb: fallthrough
        case is PowerUp:
            entity.decay()
        case is Explosion: entity.destroy()
        case let player as Player:
            player.control()
            updateHudForPlayer(player)
        case is Points:
            entity.float()
        default: break
        }
    }
    
    func entityDidAttack(_ entity: Entity) {
        entity.roam()
    }
    
    func entityWillSpawn(_ entity: Entity) {
        if entity is Player,
            let visualComponent = entity.component(ofType: VisualComponent.self) {
            let position = positionForGridPosition(entity.gridPosition)
            visualComponent.spriteNode.position = position
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension Game : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.node as! SpriteNode?
        let secondBody = contact.bodyB.node as! SpriteNode?
        
        let entity1 = firstBody?.entity
        let entity2 = secondBody?.entity
                
        if entity1 is Projectile && entity2 != nil  {
            handleContactBetweenProjectile(entity1 as! Projectile, andEntity: entity2!)
        } else if entity2 is Projectile && entity1 != nil {
            handleContactBetweenProjectile(entity2 as! Projectile, andEntity: entity1!)
        }
        
        // TODO: Currently there's a bug when player slightly out of range of explosion walks
        //  inside explosion after animation starts. The player dies. Maybe don't use physicsbody
        //  for tests between player and explosion? Or fix this issue somehow.
        if entity1 is Explosion && entity2 is Creature {
            handleContactBetweenExplosion(entity1 as! Explosion, andCreature: entity2 as! Creature)
        } else if entity2 is Explosion && entity1 is Creature {
            handleContactBetweenExplosion(entity2 as! Explosion, andCreature: entity1 as! Creature)
        } else if entity1 is Prop && entity2 is Player {
            handleContactBetweenProp(entity1 as! Prop, andPlayer: entity2 as! Player)
        } else if entity2 is Prop && entity1 is Player {
            handleContactBetweenProp(entity2 as! Prop, andPlayer: entity1 as! Player)
        } else if entity2 is PowerUp && entity1 is Player {
            handleContactBetweenPowerUp(entity2 as! PowerUp, andPlayer: entity1 as! Player)
        } else if entity1 is PowerUp && entity2 is Player {
            handleContactBetweenPowerUp(entity1 as! PowerUp, andPlayer: entity2 as! Player)
        } else if entity1 is Player && entity2 is Monster {
            handleContactBetweenMonster(entity2 as! Monster, andPlayer: entity1 as! Player)
        } else if entity2 is Player && entity1 is Monster {
            handleContactBetweenMonster(entity1 as! Monster, andPlayer: entity2 as! Player)
        } else if entity1 is Monster && entity2 is Monster {
            handleContactBetweenMonster(entity1 as! Monster, andMonster: entity2 as! Monster)
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
    }
}
