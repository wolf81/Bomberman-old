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

class Game: NSObject, EntityDelegate, SKPhysicsContactDelegate {
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
    
    // Players are referenced from the creatures array as it contains both players and monsters.
    private(set) weak var player1: Player?
    private(set) weak var player2: Player?
    
    // Lists of entities to be added or removed in the next update.
    private var entitiesToAdd = [Entity]()
    private var entitiesToRemove = [Entity]()
    
    // The previous update time is used to calculate the delta time. Entities, components, etc...
    //  are updated using the delta time (time difference since last update).
    private var previousUpdateTime: NSTimeInterval = -1
    
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
    func update(currentTime: CFTimeInterval) {
        // Make sure the previous update time is never negative (e.g.: due to overflow of time 
        //  interval)
        if self.previousUpdateTime < 0 {
            self.previousUpdateTime = currentTime
        }

        // Add new entities (e.g. dropped bombs) and remove destroyed entities (e.g. killed monsters)
        updateEntityLists()
        
        // when all players are dead or monsters are dead, finish game appropriately.
        let playerAlive = isPlayerAlive()
        let monsterAlive = isMonsterAlive()
        
        let win = playerAlive && !monsterAlive
        let loss = monsterAlive && !playerAlive
        
        if win {
            self.player1?.cheer()
            self.player2?.cheer()
        } else if loss {
            finishLevel(false)
        }
        
        let deltaTime = currentTime - self.previousUpdateTime;
        self.timeRemaining -= deltaTime
        self.previousUpdateTime = currentTime;
        
        // Update player movement, monster movement, state machines ...
        updateComponentSystems(deltaTime)
        
        self.player1?.updateWithDeltaTime(deltaTime)
        self.player2?.updateWithDeltaTime(deltaTime)
        self.powerUps.forEach({ $0.updateWithDeltaTime(deltaTime) })
        
        // Enrage timer. When timer is expired, monsters become more dangerous.
        if self.timeRemaining > 0 && !self.isLevelCompleted {
            self.gameScene?.updateTimeRemaining(self.timeRemaining)
            
            if self.timeRemaining < 30 && self.hurryUpShown == false {
                self.hurryUpShown = true
                
                let play = SKAction.playSoundFileNamed("HurryUp.caf", waitForCompletion: false)
                self.gameScene?.runAction(play)
            }
        } else if !self.timeExpired {
            self.timeExpired = true
            enrageMonsters()
        }
    }
    
    func configureLevel() {
        self.removeAllEntities()
        
        self.gameScene?.world.removeAllChildren()
        self.isLevelCompleted = false

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
                    
                    // NOTE: We don't parse powers here, instead power entites are added when tiles 
                    //  are destroyed. The reason for this is that powers need to self-destruct 
                    //  after a set amount of time and self destruct is triggered after spawn state.
                }
            }

            self.timeRemaining = level.timer
            
            if let music = level.music {
                do {
                    try MusicPlayer.sharedInstance.playMusic(music)
                } catch let error {
                    // TODO: Proper error handling
                    print(error)
                }
            }
        }
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
            for y in gridPosition.y ..< self.level!.height {
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
            for x in (gridPosition.x ..< self.level!.width) {
                gridPositions.append(Point(x: x, y: gridPosition.y))
            }
        default: break
        }
        
        for (index, gridPosition) in gridPositions.enumerate() {
            if tileAtGridPosition(gridPosition) != nil {
                gridPositions.removeRange(index ..< gridPositions.count)
                break
            }
        }
        
        return gridPositions
    }
    
    // MARK: - Private
    
    private func enrageMonsters() {
        self.creatures
            .filter({ $0 is Monster })
            .forEach({
                if let visualComponent = $0.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.speed *= 1.6
                }
            })
    }
    
    private func updateHudForPlayer(player: Player) {
        self.gameScene?.updateHudForPlayer(player)
    }
    
    private func updateComponentSystems(deltaTime: NSTimeInterval) {
        self.cpuControlSystem.updateWithDeltaTime(deltaTime)
        self.playerControlSystem.updateWithDeltaTime(deltaTime)
        self.stateMachineSystem.updateWithDeltaTime(deltaTime)
    }
    
    private func updateEntityLists() {
        for entity in self.entitiesToRemove {
            switch entity {
            case is Explosion: self.explosions.remove(entity as! Explosion)
            case is Bomb: self.bombs.remove(entity as! Bomb)
            case is Tile: self.tiles.remove(entity as! Tile)
            case is Creature: self.creatures.remove(entity as! Creature)
            case is Projectile: self.projectiles.remove(entity as! Projectile)
            case is Prop: self.props.remove(entity as! Prop)
            case is Points: self.points.remove(entity as! Points)
            case is PowerUp: self.powerUps.remove(entity as! PowerUp)
            default: print("unhandled entity type for instance: \(entity)")
            }
            
            if let visualComponent = entity.componentForClass(VisualComponent) {
                visualComponent.spriteNode.removeFromParent()
            }
            
            self.playerControlSystem.removeComponentWithEntity(entity)
            self.cpuControlSystem.removeComponentWithEntity(entity)
            self.stateMachineSystem.removeComponentWithEntity(entity)
        }
        entitiesToRemove.removeAll()
        
        for entity in self.entitiesToAdd {
            entity.delegate = self
            
            switch entity {
            case is Bomb: self.bombs.append(entity as! Bomb)
            case is Explosion: self.explosions.append(entity as! Explosion)
            case is Tile: self.tiles.append(entity as! Tile)
            case is Creature: self.creatures.append(entity as! Creature)
            case is Projectile: self.projectiles.append(entity as! Projectile)
            case is Prop: self.props.append(entity as! Prop)
            case is Points: self.points.append(entity as! Points)
            case is PowerUp: self.powerUps.append(entity as! PowerUp)
            default: print("unhandled entity type for instance: \(entity)")
            }
            
            if let visualComponent = entity.componentForClass(VisualComponent) {
                visualComponent.spriteNode.position = positionForGridPosition(entity.gridPosition)
                self.gameScene?.world.addChild(visualComponent.spriteNode)
            }
            
            self.playerControlSystem.addComponentWithEntity(entity)
            self.cpuControlSystem.addComponentWithEntity(entity)
            self.stateMachineSystem.addComponentWithEntity(entity)
        }
        self.entitiesToAdd.removeAll()
    }
    
    private func finishLevel(didPlayerWin: Bool) {
        if self.isLevelCompleted == false {
            self.isLevelCompleted = true
            
            let delay = 2.0
            
            MusicPlayer.sharedInstance.fadeOut(delay)

            let wait = SKAction.waitForDuration(delay)
            let soundFile = didPlayerWin ? "CompleteLevel.caf" : "GameOver.caf"
            let play = SKAction.playSoundFileNamed(soundFile, waitForCompletion: false)
            let sequence = SKAction.sequence([wait, play, wait]);
            
            self.gameScene?.runAction(sequence, completion: {
                // TODO: Maybe remove, since during 'configure' (level loading) we remove all 
                //  entities anyway.
                self.removeAllEntities()
                self.gameScene!.levelFinished(self.level!)            
            })
        }
    }

    private func isMonsterAlive() -> Bool {
        var isMonsterAlive = false
        
        for creature in self.creatures {
            if creature.isKindOfClass(Monster) {
                isMonsterAlive = true
                break
            }
        }
        
        return isMonsterAlive
    }
    
    private func isPlayerAlive() -> Bool {
        let isPlayerAlive = self.player1!.lives >= 0 || self.player2!.lives >= 0
        return isPlayerAlive
    }
    
    private func removeAllEntities() {
        self.entitiesToAdd.removeAll()
        self.entitiesToRemove.removeAll()
        
        self.creatures.removeAll()
        self.props.removeAll()
        self.bombs.removeAll()
        self.explosions.removeAll()
        self.tiles.removeAll()
        self.projectiles.removeAll()
        self.points.removeAll()
        self.powerUps.removeAll()
        
        self.stateMachineSystem.removeAllComponents()
        self.cpuControlSystem.removeAllComponents()
        self.playerControlSystem.removeAllComponents()
    }

    // MARK: - Public
    
    func addEntity(entity: Entity) {
        self.entitiesToAdd.append(entity)
        
        switch entity {
        case is Tile:
            let tile = entity as! Tile
            
            // TODO (workaround): because tile loading uses different path compared to entity
            //  loading and we still need to add a state machine.
            if tile.tileType == .DestructableBlock {
                let stateMachineComponent = StateMachineComponent(game: self, entity: tile, states: [SpawnState(), DestroyState()])
                tile.addComponent(stateMachineComponent)
            }
        case is Player:
            let player = entity as! Player

            switch player.index {
            case .Player1: self.player1 = player
            case .Player2: self.player2 = player
            }
        
            updateHudForPlayer(player)
        default: break
        }
    }
    
    func removeEntity(entity: Entity) {
        self.entitiesToRemove.append(entity)
    }
    
    func bombCountForPlayer(player: PlayerIndex) -> Int {
        let count = self.bombs.filter { $0.player == player }.count
        return count
    }
}

// MARK: - Entity Search -

extension Game {
    func playerAtGridPosition(gridPosition: Point) -> Creature? {
        var entity: Creature?
        
        for player in [self.player1, self.player2] {
            if pointEqualToPoint(player!.gridPosition, point2: gridPosition) {
                entity = player
                break
            }
        }
        
        return entity
    }
    
    func bombAtGridPosition(gridPosition: Point) -> Bomb? {
        var entity: Bomb?
        
        for bomb in self.bombs {
            if pointEqualToPoint(bomb.gridPosition, point2: gridPosition) {
                entity = bomb
                break
            }
        }
        
        return entity
    }
    
    func creatureAtGridPosition(gridPosition: Point) -> Creature? {
        var entity: Creature? = nil
        
        for creature in self.creatures {
            if let visualComponent = creature.componentForClass(VisualComponent) {
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
        
        for tile in self.tiles {
            if pointEqualToPoint(tile.gridPosition, point2: gridPosition) {
                entity = tile
                break
            }
        }
        
        return entity
    }
    
    func powerAtGridPosition(gridPosition: Point) -> PowerUp? {
        var entity: PowerUp? = nil
        
        for powerUp in self.powerUps {
            if pointEqualToPoint(powerUp.gridPosition, point2: gridPosition) {
                entity = powerUp
                break
            }
        }
        
        return entity
    }
}

// MARK: - EntityDelegate -

extension Game {
    func entityWillDestroy(entity: Entity) {
        switch entity {
        case is Bomb:
            let bomb = entity as! Bomb
            do {
                try bomb.explodeAtGridPosition(entity.gridPosition)
            } catch let error {
                print("error: \(error)")
            }
//            let shake = SKAction.shake(self.gameScene!.world.position, duration: 0.5)
//            self.gameScene?.world.runAction(shake)
        case is Tile:
            if let power = self.level?.powerUpAtGridPosition(entity.gridPosition) {
                addEntity(power)
            }
        case is Explosion:
            // We only want explosions to interact with other entities during spawn. 
            //  After spawning, other entities (e.g. players) should be able to walk through the 
            //  explosion animation.
            entity.removePhysicsBody()
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
    }
    
    func entityDidDecay(entity: Entity) {
        switch entity {
        case is Bomb: entity.destroy()
        case is PowerUp: entity.destroy()
        default: break
        }
    }
    
    func entityDidDestroy(entity: Entity) {
        switch entity {
        case is Bomb:
            removeEntity(entity)
        case is Creature: fallthrough
        case is Player:
            let creature = entity as! Creature

            if let player = creature as? Player {
                updateHudForPlayer(player)
                player.spawn()
            }
            
            if creature.lives < 0 {
                removeEntity(entity)
            }
        case is Tile:
            removeEntity(entity)
        default:
            removeEntity(entity)
        }
    }
    
    func entityDidHit(entity: Entity) {
        switch entity {
        case is Player:
            let player = entity as! Player
            if !player.isDestroyed {
                player.control()
            }
            updateHudForPlayer(player)
        case is Projectile:
            entity.destroy()
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
        case is Bomb: entity.decay()
        case is PowerUp: entity.decay()
        case is Explosion: entity.destroy()
        case is Projectile:
            if let vc = entity.componentForClass(VisualComponent) {
                var dx: CGFloat = 0.0, dy: CGFloat = 0.0
                let force: CGFloat = 0.7
                
                switch entity.direction {
                case .Up: dy = force
                case .Down: dy = -force
                case .Right: dx = force
                case .Left: dx = -force
                default: break
                }
                
            vc.spriteNode.physicsBody?.applyForce(CGVector(dx: dx, dy: dy))
            }
        case is Player:
            if let player = entity as? Player {
                player.control()
                updateHudForPlayer(player)
            }
        case is Points:
            entity.float()
        default: break
        }
    }
    
    func entityDidAttack(entity: Entity) {
        entity.roam()
    }
    
    func entityWillSpawn(entity: Entity) {
        if entity is Player {
            if let visualComponent = entity.componentForClass(VisualComponent) {
                let position = positionForGridPosition(entity.gridPosition)
                visualComponent.spriteNode.position = position
            }
        }
    }
}

// MARK: - Collision Handling -

extension Game {
    // MARK: SKPhysicsContactDelegate
    
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
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
//        print("didEndContact")
    }
    
    // MARK: Private
    
    private func handleContactBetweenExplosion(explosion: Explosion, andCreature creature: Creature) {
        creature.destroy()
    }
    
    private func handleContactBetweenProjectile(projectile: Projectile, andEntity entity: Entity) {
        projectile.hit()
        
        if let player = entity as? Player where player.isDestroyed == false {
            player.hit()
        }
    }
    
    private func handleContactBetweenProp(prop: Prop, andPlayer player: Player) {
        prop.destroy()
    }
    
    private func handleContactBetweenPowerUp(powerUp: PowerUp, andPlayer player: Player) {
        powerUp.hit()
        
        if powerUp.activated == false {
            powerUp.activate(forPlayer: player)
            updateHudForPlayer(player)            
        }
     }
}