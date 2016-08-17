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

class Game: NSObject {
    static let sharedInstance = Game()
    
    // Control systems for the player, computer and generic state machine (e.g.: tiles are not 
    //  'played' by the CPU, but can still have several states - some tiles can be destroyed).
    private let cpuControlSystem = ComponentSystem(componentClass: CpuControlComponent.self)
    private let playerControlSystem = ComponentSystem(componentClass: PlayerControlComponent.self)
    private let stateMachineSystem = ComponentSystem(componentClass: StateMachineComponent.self)
    
    // The current level. After the level is assigned, we add all entities of the level to the 
    //  entity lists of the game.
    private var level: Level? = nil
    
    private var isLevelCompleted = false
    
    // Enrage timer for monsters.
    private var timeRemaining: NSTimeInterval = 0
    private var timeExpired = false
    private var hurryUpShown = false
    
    private(set) var gameScene: GameScene? = nil
    
    // List of entities currently active in the game. These lists are updated each game loop.
    private(set) var creatures = [Creature]()
    private(set) var props = [Entity]()
    private(set) var bombs = [Bomb]()
    private(set) var explosions = [Explosion]()
    private(set) var tiles = [Tile]()
    private(set) var projectiles = [Projectile]()
    private(set) var points = [Points]()
    private(set) var powerUps = [PowerUp]()
    private(set) var coins = [Coin]()
    
    // Players are referenced from the creatures array as it contains both players and monsters.
    private(set) weak var player1: Player?
    private(set) weak var player2: Player?
    
    // Lists of entities to be added or removed in the next update.
    private var entitiesToAdd = [Entity]()
    private var entitiesToRemove = [Entity]()
    
    func configureForGameScene(gameScene: GameScene) {
        self.level = gameScene.level
        self.gameScene = gameScene
        self.gameScene?.physicsWorld.contactDelegate = self
    }
        
    func handlePlayerDidStartAction(player: PlayerIndex, action: PlayerAction) {
        switch player {
        case .Player1:
            if let playerControlComponent = level?.player1?.componentForClass(PlayerControlComponent) {
                playerControlComponent.addAction(action)
            }
        case .Player2:
            if let playerControlComponent = level?.player2?.componentForClass(PlayerControlComponent) {
                playerControlComponent.addAction(action)
            }
        }
    }
    
    func handlePlayerDidStopAction(player: PlayerIndex, action: PlayerAction) {
        switch player {
        case .Player1:
            if let playerControlComponent = level?.player1?.componentForClass(PlayerControlComponent) {
                playerControlComponent.removeAction(action)
            }
        case .Player2:
            if let playerControlComponent = level?.player2?.componentForClass(PlayerControlComponent) {
                playerControlComponent.removeAction(action)
            }
        }
    }
    
    // The main update loop. Called every frame to update game state.
    func update(deltaTime: CFTimeInterval) {
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
        
        // Update player movement, monster movement, state machines ...
        updateComponentSystems(deltaTime)
        
        player1?.updateWithDeltaTime(deltaTime)
        player2?.updateWithDeltaTime(deltaTime)
        powerUps.forEach({ $0.updateWithDeltaTime(deltaTime) })
        
        // Enrage timer. When timer is expired, monsters become more dangerous.
        if timeRemaining > 0 && !isLevelCompleted {
            gameScene?.updateTimeRemaining(timeRemaining)
            
            if timeRemaining < 30 && hurryUpShown == false {
                hurryUpShown = true
                
                let play = SKAction.playSoundFileNamed("HurryUp.caf", waitForCompletion: false)
                gameScene?.runAction(play)
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
    
    func nextVisibleGridPositionFromGridPosition(gridPosition: Point, inDirection direction: Direction) -> Point? {
        var nextGridPosition: Point?
        
        switch direction {
        case .Up: nextGridPosition = Point(x: gridPosition.x, y: gridPosition.y + 1)
        case .Down: nextGridPosition = Point(x: gridPosition.x, y: gridPosition.y - 1)
        case .Left: nextGridPosition = Point(x: gridPosition.x - 1, y: gridPosition.y)
        case .Right: nextGridPosition = Point(x: gridPosition.x + 1, y: gridPosition.y)
        default: break
        }
    
        if nextGridPosition != nil {
            if tileAtGridPosition(nextGridPosition!) != nil {
                nextGridPosition = nil
            }
        }
        
        return nextGridPosition
    }
    
    func visibleGridPositionsFromGridPosition(gridPosition: Point, inDirection direction: Direction) -> [Point] {
        var gridPositions = [Point]()
        
        switch direction {
        case .Up:
            for y in gridPosition.y ..< level!.height {
                gridPositions.append(Point(x: gridPosition.x, y: y))
            }
        case .Down:
            for y in (0 ..< gridPosition.y).reverse() {
                gridPositions.append(Point(x: gridPosition.x, y: y))
            }
        case .Left:
            for x in (0 ..< gridPosition.x).reverse() {
                gridPositions.append(Point(x: x, y: gridPosition.y))
            }
        case .Right:
            for x in (gridPosition.x ..< level!.width) {
                gridPositions.append(Point(x: x, y: gridPosition.y))
            }
        default: break
        }
        
        for (index, gridPosition) in gridPositions.enumerate() where tileAtGridPosition(gridPosition) != nil {
            gridPositions.removeRange(index ..< gridPositions.count)
            break
        }
        
        return gridPositions
    }
    
    // MARK: - Private
    
    private func playMusic() {
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
    
    private func enrageMonsters() {
        creatures
            .filter({ $0 is Monster })
            .forEach({
                if let visualComponent = $0.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.speed *= 1.6
                }
            })
    }
    
    private func updateHudForPlayer(player: Player) {
        gameScene?.updateHudForPlayer(player)
    }
    
    private func updateComponentSystems(deltaTime: NSTimeInterval) {
        cpuControlSystem.updateWithDeltaTime(deltaTime)
        playerControlSystem.updateWithDeltaTime(deltaTime)
        stateMachineSystem.updateWithDeltaTime(deltaTime)
    }
    
    private func updateEntityLists() {
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
            
            if let visualComponent = entity.componentForClass(VisualComponent) {
                visualComponent.spriteNode.removeFromParent()
            }
            
            playerControlSystem.removeComponentWithEntity(entity)
            cpuControlSystem.removeComponentWithEntity(entity)
            stateMachineSystem.removeComponentWithEntity(entity)
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
            
            if let visualComponent = entity.componentForClass(VisualComponent) {
                visualComponent.spriteNode.position = positionForGridPosition(entity.gridPosition)
                gameScene?.world.addChild(visualComponent.spriteNode)
            }
            
            playerControlSystem.addComponentWithEntity(entity)
            cpuControlSystem.addComponentWithEntity(entity)
            stateMachineSystem.addComponentWithEntity(entity)
        }
        entitiesToAdd.removeAll()
    }
    
    private func finishLevel(didPlayerWin: Bool) {
        if isLevelCompleted == false {
            isLevelCompleted = true
            
            let delay = 2.0
            
            MusicPlayer.sharedInstance.fadeOut(delay)

            let wait = SKAction.waitForDuration(delay)
            let soundFile = didPlayerWin ? "CompleteLevel.caf" : "GameOver.caf"
            let play = SKAction.playSoundFileNamed(soundFile, waitForCompletion: false)
            let sequence = SKAction.sequence([wait, play, wait]);
            
            gameScene?.runAction(sequence, completion: {
                // TODO: Maybe remove, since during 'configure' (level loading) we remove all 
                //  entities anyway.
                self.removeAllEntities()
                self.gameScene!.levelFinished(self.level!)            
            })
        }
    }

    private func isMonsterAlive() -> Bool {
        var isMonsterAlive = false
        
        for creature in creatures where creature.isKindOfClass(Monster) {
            isMonsterAlive = true
            break
        }
        
        return isMonsterAlive
    }
    
    private func isPlayerAlive() -> Bool {
        let players = [player1, player2].flatMap{ $0 }.filter{ $0.lives >= 0 }
        return players.count > 0
    }
    
    private func removeAllEntities() {
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

    // MARK: - Private (Collision Handling)
    
    private func handleContactBetweenExplosion(explosion: Explosion, andCreature creature: Creature) {
        creature.destroy()
    }
    
    private func handleContactBetweenProjectile(projectile: Projectile, andEntity entity: Entity) {
        projectile.hit()
        
        if let player = entity as? Player where player.isDestroyed == false {
            player.hit(projectile.damage)
        }
    }
    
    private func handleContactBetweenProp(prop: Prop, andPlayer player: Player) {
        prop.destroy()
        
        let coinsInLevel = coins.filter { (coin) -> Bool in
            coin.isDestroyed == false
        }
        
        if coinsInLevel.count == 0 && timeRemaining > 0 {
            let monsters = creatures.filter({ (creature) -> Bool in
                return creature is Monster
            })
            
            let creatureLoader = CreatureLoader(forGame: self)
            var aliens = [Creature]()
            
            for monster in monsters {
                do {
                    if let alien = try creatureLoader.monsterWithName("Alien", gridPosition: monster.gridPosition) {
                        aliens.append(alien)
                        
                        if let monsterVc = monster.componentForClass(VisualComponent), let alienVc = alien.componentForClass(VisualComponent) {
                            alienVc.spriteNode.position = monsterVc.spriteNode.position
                        }
                        
                        removeEntity(monster)
                        addEntity(alien)
                    }
                } catch let error {
                    updateInfoOverlayWithMessage("\(error)")
                }
            }
            
            print("change monsters into blobs")
        }
    }
    
    private func handleContactBetweenMonster(monster: Monster, andPlayer player: Player) {
        player.moveInDirection(.None)
    }
    
    private func handleContactBetweenPowerUp(powerUp: PowerUp, andPlayer player: Player) {
        powerUp.hit()
        
        if powerUp.activated == false {
            powerUp.activate(forPlayer: player)
            updateHudForPlayer(player)
        }
    }
    
    // MARK: - Public
    
    func addEntity(entity: Entity) {
        entitiesToAdd.append(entity)
        
        switch entity {
        case let tile as Tile:
            // TODO (workaround): because tile loading uses different path compared to entity
            //  loading and we still need to add a state machine.
            if tile.tileType == .DestructableBlock {
                let stateMachineComponent = StateMachineComponent(game: self, entity: tile, states: [SpawnState(), DestroyState()])
                tile.addComponent(stateMachineComponent)
            }
        case let player as Player:
            switch player.index {
            case .Player1: player1 = player
            case .Player2: player2 = player
            }
        
            updateHudForPlayer(player)
        default: break
        }
    }
    
    func removeEntity(entity: Entity) {
        entitiesToRemove.append(entity)
    }
    
    func bombCountForPlayer(player: PlayerIndex) -> Int {
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
    
    func playerAtGridPosition(gridPosition: Point) -> Player? {
        var entity: Player?
        
        let players = [player1, player2].flatMap{ $0 }
        
        for player in players where pointEqualToPoint(player.gridPosition, point2: gridPosition) {
            entity = player
            break
        }
        
        return entity
    }
    
    func bombAtGridPosition(gridPosition: Point) -> Bomb? {
        var entity: Bomb?
        
        for bomb in bombs where pointEqualToPoint(bomb.gridPosition, point2: gridPosition) {
            entity = bomb
            break
        }
        
        return entity
    }
    
    func creatureAtGridPosition(gridPosition: Point) -> Creature? {
        var entity: Creature? = nil
        
        for creature in creatures {
            if let visualComponent = creature.componentForClass(VisualComponent) {
                // We don't use the creature grid position property directly, since it's not
                //  updated until a creature finishes walking to a node. Instead we translate
                //  the creatures' sprite position to a grid position.
                let position = visualComponent.spriteNode.position
                let creatureGridPosition = gridPositionForPosition(position)
                
                if pointEqualToPoint(creatureGridPosition, point2: gridPosition) {
                    entity = creature
                }
            }
        }
        
        return entity
    }
    
    func tileAtGridPosition(gridPosition: Point) -> Tile? {
        var entity: Tile? = nil
        
        for tile in tiles where pointEqualToPoint(tile.gridPosition, point2: gridPosition) {
            entity = tile
            break
        }
        
        return entity
    }
    
    func bossAtGridPosition(gridPosition: Point) -> Monster? {
        var boss: Monster? = nil
        
        for creature in creatures {
            guard
                let monster = creature as? Monster,
                let configComponent = monster.componentForClass(ConfigComponent)
                where configComponent.creatureType == .Boss else { return nil }
            
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
    
    func powerAtGridPosition(gridPosition: Point) -> PowerUp? {
        var entity: PowerUp? = nil
        
        for powerUp in powerUps where pointEqualToPoint(powerUp.gridPosition, point2: gridPosition) {
            entity = powerUp
            break
        }
        
        return entity
    }
}

// MARK: - EntityDelegate

extension Game : EntityDelegate {
    func entityWillDestroy(entity: Entity) {
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
    
    func entityDidCheer(entity: Entity) {
        finishLevel(true)
        
        if let player = entity as? Player {
            player.control()
        }
    }
    
    func entityDidDecay(entity: Entity) {
        switch entity {
        case is Bomb: fallthrough
        case is PowerUp:
            entity.destroy()
        default: break
        }
    }
    
    func entityDidDestroy(entity: Entity) {
        switch entity {
        case let player as Player:
            updateHudForPlayer(player)
            player.spawn()
            
            if player.lives < 0 {
                removeEntity(entity)
            }
        case let creature as Creature where creature.lives < 0: fallthrough
        case is Bomb: fallthrough
        case is Tile: fallthrough
        default:
            removeEntity(entity)
        }
    }
    
    func entityDidHit(entity: Entity) {
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
    
    func entityDidFloat(entity: Entity) {
        switch entity {
        case is Points: entity.destroy()
        default: break
        }
    }
    
    func entityDidSpawn(entity: Entity) {
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
    
    func entityDidAttack(entity: Entity) {
        entity.roam()
    }
    
    func entityWillSpawn(entity: Entity) {
        if entity is Player,
            let visualComponent = entity.componentForClass(VisualComponent) {
            let position = positionForGridPosition(entity.gridPosition)
            visualComponent.spriteNode.position = position
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension Game : SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.node as! SpriteNode?
        let secondBody = contact.bodyB.node as! SpriteNode?
        
        let entity1 = firstBody?.entity
        let entity2 = secondBody?.entity
                
        if entity1 is Projectile  {
            handleContactBetweenProjectile(entity1 as! Projectile, andEntity: entity2!)
        } else if entity2 is Projectile {
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
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
    }
}
