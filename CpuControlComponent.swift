//
//  CpuControlComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit
import CoreGraphics

class CpuControlComponent: GKComponent {
    private var attackDelay: NSTimeInterval = -1.0
    
    private(set) weak var game: Game?
    
    private var didRoam = false
    
    private var creature: Creature? {
        return entity as! Creature?
    }
    
    init(game: Game) {
        self.game = game
        
        super.init()
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if let stateMachineComponent = entity?.componentForClass(StateMachineComponent) {
            if stateMachineComponent.currentState == nil && stateMachineComponent.canRoam {
                if !didRoam {
                    stateMachineComponent.enterRoamState()
                    didRoam = true
                }
            } else {
                guard let creature = self.creature else { return }
                
                if creature.direction == .None {
                    let direction = randomDirectionForCreature(creature)
                    creature.direction = direction
                    creature.roam()                    
               } else {
                    for monster in Game.sharedInstance.creatures where monster is Monster {
                        if monster != creature {
                            guard
                                let monsterVc = monster.componentForClass(VisualComponent),
                                let creatureVc = creature.componentForClass(VisualComponent) else {
                                    continue
                            }
                            
                            let offset = CGFloat(10.0)
                            var creatureRect = creatureVc.spriteNode.frame
                            creatureRect = CGRectInset(creatureRect, -offset, -offset)
                            
                            let monsterRect = monsterVc.spriteNode.frame
                            if CGRectIntersectsRect(creatureRect, monsterRect) {
//                                creature.stop()
                                let direction = randomDirectionForCreature(creature)
                                creature.direction = direction
                                creature.roam()
                            }
                        }
                    }
                }
                
//                if creature.canAttack && creature.isDestroyed == false {
//                    attackDelay -= seconds
//                    
//                    if attackDelay < 0 {
//                        if let projectileName = configComponent.projectile {
//                            if attemptRangedAttackWithProjectile(projectileName, forCreature: creature, direction: configComponent.attackDirection) {
//                                attackDelay = creature.abilityCooldown
//                            }
//                        } else {
//                            if attemptMeleeAttackForCreature(creature) {
//                                attackDelay = creature.abilityCooldown
//                            }
//                        }
//                    }
//                }
            }
        }
    }
    
    private func randomDirectionForCreature(creature: Creature) -> Direction {
        var direction: Direction = .None
        
        guard let creatureVc = creature.componentForClass(VisualComponent) else {
            return .None
        }
        
        var directions = creature.movementDirectionsFromCurrentGridPosition()

        for monster in Game.sharedInstance.creatures where monster is Monster {
            if monster != creature {
                guard
                    let monsterVc = monster.componentForClass(VisualComponent) else {
                    continue
                }
                
                // 1. bereken volgende frame voor creature gebaseerd op direction
                // 2. bereken volgende frame voor monster gebaseerd op direction
                // 3. als creature frame botst met monster frame, remove
                
                let offset = CGFloat(10.0)
                var creatureRect = creatureVc.spriteNode.frame
                creatureRect = CGRectInset(creatureRect, -offset, -offset)
                
                let monsterRect = monsterVc.spriteNode.frame
                if CGRectIntersectsRect(creatureRect, monsterRect) {
                    for (idx, direction) in directions.enumerate() {
                        let origin = positionForGridPosition(direction.gridPosition)
                        let size = CGSize(width: unitLength, height: unitLength)
                        let rect = CGRect(origin: origin, size: size)
                        if CGRectIntersectsRect(rect, monsterRect) {
                            directions.removeAtIndex(idx)
                            break
                        }
                    }
                }
            }
        }
        
        if directions.count > 0 {
            let idx = arc4random() % UInt32(directions.count)
            direction = directions[Int(idx)].direction
        } else {
            creature.stop()
        }
        
        return direction
    }
    
    private func attemptRangedAttackWithProjectile(projectile: String, forCreature creature: Creature, direction: AttackDirection) -> Bool {
        var didAttack = false
        
        if launchProjectileToPlayer(projectile, forCreature: creature, direction: direction) {
            creature.attack()
            didAttack = true
        }
        
        return didAttack
    }
    
    private func attemptMeleeAttackForCreature(creature: Creature) -> Bool {
        var didAttack = false
        
        if let player = playerInRangeForMeleeAttack() {
            creature.attack()
            
            if let configComponent = creature.componentForClass(ConfigComponent) {
                player.hit(configComponent.hitDamage)
            }
            
            didAttack = true
        }
        
        return didAttack
    }
    
    private func distanceBetweenPoint(point: Point, otherPoint: Point) -> (distance: CGFloat, dx: CGFloat, dy: CGFloat) {
        let dx = CGFloat(point.x - otherPoint.x)
        let dy = CGFloat(point.y - otherPoint.y)
        let distance = fmax(hypot(dx, dy), 1.0)
        
        return (distance, dx, dy)
    }
    
    private func fireProjectile(name: String, withOrigin origin: Point, distance: CGFloat, dx: CGFloat, dy: CGFloat) {
        let speed = CGFloat(unitLength)
        let factor = 1.0 / distance * speed
        let force = CGVector(dx: dx * factor, dy: dy * factor)
        addProjectileWithName(name, toGame: game!, withForce: force, gridPosition: origin)
    }
    
    private func findClosestPlayerFromPlayers(players: [Player], fromOrigin origin: Point) -> (player: Player, distance: CGFloat, offset: (dx: CGFloat, dy: CGFloat)) {
        var player: Player = players.first!
        var distance: CGFloat = CGFloat.max
        var offset: (dx: CGFloat, dy: CGFloat) = (dx: 0, dy: 0)
        
        for testPlayer in players {
            let result = distanceBetweenPoint(testPlayer.gridPosition, otherPoint: origin)
            if result.distance < distance {
                player = testPlayer
                distance = result.distance
                offset = (dx: result.dx, dy: result.dy)
            }
        }
        
        return (player, distance, offset)
    }
    
    private func launchProjectileToPlayer(entityName: String, forCreature creature: Creature, direction: AttackDirection) -> Bool {
        var didLaunchProjectile = false
        
        let players = [game?.player1, game?.player2].flatMap{ $0 }
        let creaturePos = creature.gridPosition

        let result = findClosestPlayerFromPlayers(players, fromOrigin: creature.gridPosition)

        switch direction {
        case .Any:
            fireProjectile(entityName, withOrigin: creaturePos, distance: result.distance, dx: result.offset.dx, dy: result.offset.dy)
            
            didLaunchProjectile = true
        case .Axial:
            if result.offset.dx == 0 || result.offset.dy == 0 {
                let visibleGridPositions = game!.visibleGridPositionsFromGridPosition(creaturePos, inDirection: creature.direction)

                let playerPos = result.player.gridPosition
                for gridPosition in visibleGridPositions where pointEqualToPoint(gridPosition, playerPos) {
                    fireProjectile(entityName, withOrigin: creaturePos, distance: result.distance, dx: result.offset.dx, dy: result.offset.dy)
                    didLaunchProjectile = true
                }
            }
        }
        
        return didLaunchProjectile
    }
    
    private func addProjectileWithName(name: String, toGame game: Game, withForce force: CGVector, gridPosition: Point) {
        let propLoader = PropLoader(forGame: game)
        
        do {
            if let projectile = try propLoader.projectileWithName(name, gridPosition: gridPosition, force: force) {
                if let visualComponent = projectile.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.position = positionForGridPosition(gridPosition)
                }
                
                self.game?.addEntity(projectile)
            }
        } catch let error {
            print("error: \(error)")
        }
    }
    
    private func playerInRangeForMeleeAttack() -> Player? {
        var player: Player?
                
        if let creature = self.creature {
            let gridPosition = creature.gridPosition
            let direction = creature.direction
            
            var visibleGridPositions: [Point] = [gridPosition]
            
            if let nextGridPosition = game?.nextVisibleGridPositionFromGridPosition(gridPosition, inDirection: direction) {
                visibleGridPositions.append(nextGridPosition)
            }
            
            for visibleGridPosition in visibleGridPositions {
                if let nearbyPlayer = game?.playerAtGridPosition(visibleGridPosition) where nearbyPlayer.isControllable {
                    player = nearbyPlayer
                    break
                }
            }
        }
        
        return player
    }
}