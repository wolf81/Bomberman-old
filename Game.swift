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
    private let cpuControlSystem = GKComponentSystem(componentClass: CpuControlComponent.self)
    private let playerControlSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)
    private let stateMachineSystem = GKComponentSystem(componentClass: StateMachineComponent.self)
    
    // The current level. After the level is assigned, we add all entities of the level to the 
    //  entity lists of the game.
    private var level: Level? = nil
    
    private var timeRemaining: NSTimeInterval = 0
    private var timerFinished = false
    
    private(set) var gameScene: GameScene? = nil
    
    // List of entities currently active in the game. These lists are updated each game loop.
    private(set) var creatures = [Creature]()
    private(set) var props = [Entity]()
    private(set) var bombs = [Bomb]()
    private(set) var explosions = [Explosion]()
    private(set) var tiles = [Tile]()
    private(set) var projectiles = [Projectile]()
    private(set) var points = [Points]()
    
    private(set) weak var player1: Player?
    private(set) weak var player2: Player?
    
    // Lists of entities to be added or removed in the next update.
    private var entitiesToAdd = [Entity]()
    private var entitiesToRemove = [Entity]()
    
    // The previous update time is used to calculate the delta time. Entities, components, etc...
    //  are updated using the delta time (time difference since last update).
    private var previousUpdateTime: NSTimeInterval = -1
    
    func configureScene(gameScene: GameScene) {
        self.level = gameScene.level
        self.gameScene = gameScene
        self.gameScene?.physicsWorld.contactDelegate = self
    }
    
    func loadLevel(levelIndex: Int) -> Level? {
        let levelParser = LevelLoader(forGame: self)
        
        var level: Level?
        
        do {
            level = try levelParser.loadLevel(levelIndex)
        } catch let error {
            print("error: \(error)")
        }
        
        return level
    }
        
    func handlePlayerDidStartAction(scene: GameScene, player: PlayerIndex, action: PlayerAction) {
        if player == .Player1 {
            if let playerControlComponent = level?.player1?.componentForClass(PlayerControlComponent) {
                playerControlComponent.insert(action)
            }
        } else if player == .Player2 {
            if let playerControlComponent = level?.player2?.componentForClass(PlayerControlComponent) {
                playerControlComponent.insert(action)
            }
        }
    }
    
    func handlePlayerDidStopAction(scene: GameScene, player: PlayerIndex, action: PlayerAction) {
        if player == .Player1 {
            if let playerControlComponent = level?.player1?.componentForClass(PlayerControlComponent) {
                playerControlComponent.remove(action)
            }
        } else if player == .Player2 {
            if let playerControlComponent = level?.player2?.componentForClass(PlayerControlComponent) {
                playerControlComponent.remove(action)
            }
        }
    }
    
    func update(currentTime: CFTimeInterval) {
        // Make sure the previous update time is never negative (e.g.: due to overflow of time 
        //  interval)
        if self.previousUpdateTime < 0 {
            self.previousUpdateTime = currentTime
        }

        // Add new entities (e.g. dropped bombs) and remove destroyed entities (e.g. killed monsters)
        updateEntityLists()

        let deltaTime = currentTime - self.previousUpdateTime;
        self.timeRemaining -= deltaTime
        self.previousUpdateTime = currentTime;
        
        // Update player movement, monster movement, state machines ...
        updateComponentSystems(deltaTime)
        
        // when all players are dead or monsters are dead, finish game appropriately.
        if isLevelFinished() {
            self.removeAllEntities()
            self.gameScene!.levelFinished(self.level!)
        }
        
        if self.timeRemaining > 0 {
            self.gameScene?.updateTimeRemaining(self.timeRemaining)
        } else if !self.timerFinished {
            self.timerFinished = true
            accelerateMonsters()
        }
    }
    
    private func accelerateMonsters() {
        for creature in self.creatures {
            if creature is Monster {
                if let visualComponent = creature.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.speed *= 1.6
                }
            }
        }
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
            case is Points:
                self.points.append(entity as! Points)
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
    
    private func isLevelFinished() -> Bool {
        var levelFinished = true
        
        let isPlayerAlive = !self.player1!.isDestroyed || !self.player2!.isDestroyed
        
        if isPlayerAlive {
            for creature in self.creatures {
                if creature.isKindOfClass(Monster) {
                    levelFinished = false
                    break
                }
            }
        }
        
        return levelFinished
    }
    
    private func removeAllEntities() {
        self.creatures.removeAll()
        self.props.removeAll()
        self.bombs.removeAll()
        self.explosions.removeAll()
        self.tiles.removeAll()
        self.projectiles.removeAll()
        self.points.removeAll()
    }
    
    func tileAtGridPosition(gridPosition: Point) -> Tile? {
        var tile: Tile? = nil
        
        for aTile in self.tiles {
            if pointEqualToPoint(aTile.gridPosition, point2: gridPosition) {
                tile = aTile
                break
            }
        }
        
        return tile
    }
    
    func positionForGridPosition(gridPosition: Point) -> CGPoint {
        let halfUnitLength = unitLength / 2
        let position = CGPoint(x: gridPosition.x * unitLength + halfUnitLength,
                               y: gridPosition.y * unitLength + halfUnitLength)
        return position
    }
    
    func gridPositionForPosition(position: CGPoint) -> Point {
        let x = Int(position.x / CGFloat(unitLength))
        let y = Int(position.y / CGFloat(unitLength))
        
        return Point(x: x, y: y)
    }

    func configureLevel() {
        self.gameScene?.world.removeAllChildren()
        
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
                }
            }

            self.timeRemaining = level.timer
        }
    }
    
    func playerAtGridPosition(gridPosition: Point) -> Creature? {
        var player: Creature?
        
        for aPlayer in [self.player1, self.player2] {
            if pointEqualToPoint(aPlayer!.gridPosition, point2: gridPosition) {
                player = aPlayer
                break
            }
        }
        
        return player
    }
    
    func bombAtGridPosition(gridPosition: Point) -> Bomb? {
        var bomb: Bomb?
        
        for aBomb in self.bombs {
            if pointEqualToPoint(aBomb.gridPosition, point2: gridPosition) {
                bomb = aBomb
                break
            }
        }
        
        return bomb
    }
    
    func creatureAtGridPosition(gridPosition: Point) -> Creature? {
        var creature: Creature? = nil
        
        for aCreature in self.creatures {
            if let visualComponent = aCreature.componentForClass(VisualComponent) {
                let position = visualComponent.spriteNode.position
                let creatureGridPosition = gridPositionForPosition(position)
                
                if pointEqualToPoint(creatureGridPosition, point2: gridPosition) {
                    creature = aCreature
                }
            }
        }
        
        return creature
    }
    
    func nextVisibleGridPositionFromGridPosition(gridPosition: Point, inDirection direction: Direction) -> Point? {
        var nextGridPosition: Point?
        
        switch direction {
        case .North: nextGridPosition = Point(x: gridPosition.x, y: gridPosition.y + 1)
        case .South: nextGridPosition = Point(x: gridPosition.x, y: gridPosition.y - 1)
        case .West: nextGridPosition = Point(x: gridPosition.x - 1, y: gridPosition.y)
        case .East: nextGridPosition = Point(x: gridPosition.x + 1, y: gridPosition.y)
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
        case .North:
            for y in gridPosition.y ..< self.level!.height {
                gridPositions.append(Point(x: gridPosition.x, y: y))
            }
        case .South:
            for y in (0 ..< gridPosition.y).reverse() {
                gridPositions.append(Point(x: gridPosition.x, y: y))
            }
        case .West:
            for x in (0 ..< gridPosition.x).reverse() {
                gridPositions.append(Point(x: x, y: gridPosition.y))
            }
        case .East:
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
    
    func addEntity(entity: Entity) {
        self.entitiesToAdd.append(entity)
        
        if let tile = entity as? Tile {
            // TODO (workaround): because tile loading uses different path compared to entity 
            //  loading and we still need to add a state machine.
            if tile.tileType == .DestructableBlock {
                let stateMachineComponent = StateMachineComponent(game: self, entity: tile, states: [SpawnState(), DestroyState()])
                tile.addComponent(stateMachineComponent)
            }
        } else if let player = entity as? Player {
            switch player.index {
            case .Player1: self.player1 = player
            case .Player2: self.player2 = player
            }
            
            if let gameScene = self.gameScene {
                gameScene.updatePlayer(player.index, setLives: player.lives)
                gameScene.updatePlayer(player.index, setHealth: player.health)
            }
        }
    }
    
    func removeEntity(entity: Entity) {
        self.entitiesToRemove.append(entity)
    }
    
    func entityDidDestroy(entity: Entity) {
        switch entity {
        case is Bomb:
            let bomb = entity as! Bomb
            do {
                try bomb.explodeAtGridPosition(entity.gridPosition)
            } catch let error {
                print("error: \(error)")
            }
            
            let shake = SKAction.shake(self.gameScene!.world.position, duration: 0.5)
            self.gameScene?.world.runAction(shake)
            
            removeEntity(entity)
        case is Creature: fallthrough
        case is Player:
            let creature = entity as! Creature
            if creature.lives < 0 {
                removeEntity(entity)
            }
            
            if let player = creature as? Player {
                if let controlComponent = player.componentForClass(PlayerControlComponent) {
                    controlComponent.removeAllActions()
                }
                
                self.gameScene?.updatePlayer(player.index, setLives: player.lives)
                player.spawn(afterDelay: 1)
            }
        case is Tile:
            let propLoader = PropLoader(forGame: self)
            if let points = try! propLoader.pointsWithType(PointsType.Fifty, gridPosition: entity.gridPosition) {
                addEntity(points)
            }
            
            removeEntity(entity)
        default:
            removeEntity(entity)
        }
    }
    
    func entityDidHit(entity: Entity) {
        if let player = entity as? Player {
            if !player.isDestroyed {
                player.control()
            }
                
            self.gameScene?.updatePlayer(player.index, setHealth: player.health)
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
        case is Explosion: entity.destroy()
        case is Projectile: entity.propel()
        case is Player:
            if let player = entity as? Player {
                player.control()
                self.gameScene?.updatePlayer(player.index, setHealth: player.health)
            }
        case is Points:
            entity.float()
        default: break
        }
    }
    
    func entityDidAttack(entity: Entity) {
        print("entityDidAttack: \(entity)")
        
        entity.roam()
    }
    
    func handleCollisionBetweenProjectile(projectile: Projectile, andEntity entity: Entity) {
        if let player = entity as? Player {
            if player.isDestroyed == false {
                player.hit()
                projectile.destroy()
            }
        } else {
            projectile.destroy()
        }
    }
    
    func handleCollisionBetweenProp(prop: Prop, andPlayer: Player) {
        if prop.isDestroyed == false {
            prop.destroy()        
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.node as! SpriteNode?
        let secondBody = contact.bodyB.node as! SpriteNode?
        
        let entity1 = firstBody?.entity
        let entity2 = secondBody?.entity
        
        if entity1 is Projectile  {
            handleCollisionBetweenProjectile(entity1 as! Projectile, andEntity: entity2!)
        } else if entity2 is Projectile {
            handleCollisionBetweenProjectile(entity2 as! Projectile, andEntity: entity1!)
        }
        
        if entity1 is Prop && entity2 is Player {
            handleCollisionBetweenProp(entity1 as! Prop, andPlayer: entity2 as! Player)
        } else if entity2 is Prop && entity1 is Player {
            handleCollisionBetweenProp(entity2 as! Prop, andPlayer: entity1 as! Player)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
//        print("didEndContact")
    }
}