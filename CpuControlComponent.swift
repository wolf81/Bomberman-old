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
    
    private var creature: Creature? {
        return entity as! Creature?
    }
    
    init(game: Game) {
        self.game = game
        
        super.init()
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if let stateMachineComponent = self.entity?.componentForClass(StateMachineComponent) {
            if stateMachineComponent.currentState == nil && stateMachineComponent.canRoam {
                stateMachineComponent.enterRoamState()
            } else {
                if let creature = self.creature {
                    if let configComponent = creature.componentForClass(ConfigComponent) {
                        attackDelay -= seconds
                        
                        if attackDelay < 0 {
                            if let projectileName = configComponent.projectile {
                                if attemptRangedAttackWithProjectile(projectileName, forCreature: creature, direction: configComponent.attackDirection) {
                                    attackDelay = creature.abilityCooldown
                                }
                            } else {
                                if attemptMeleeAttackForCreature(creature) {
                                    attackDelay = creature.abilityCooldown
                                }
                            }
                        }
                    }
                }
            }
        }
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
        
        if playerInRangeForMeleeAttack() {
            creature.attack()
            didAttack = true
        }
        
        return didAttack
    }
    
    private func distanceBetweenPoint(point: Point, otherPoint: Point) -> (distance: CGFloat, dx: CGFloat, dy: CGFloat) {
        let dx = CGFloat(point.x - otherPoint.x)
        let dy = CGFloat(point.y - otherPoint.y)
        let distance = hypot(dx, dy)
        
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

        switch direction {
        case .Any:
            let result = findClosestPlayerFromPlayers(players, fromOrigin: creature.gridPosition)
            
            fireProjectile(entityName, withOrigin: creaturePos, distance: result.distance, dx: result.offset.dx, dy: result.offset.dy)
            
            didLaunchProjectile = true
        case .Axial:
            let result = findClosestPlayerFromPlayers(players, fromOrigin: creature.gridPosition)
            let playerPos = result.player.gridPosition
            
            if result.offset.dx == 0 || result.offset.dy == 0 {
                let visibleGridPositions = game!.visibleGridPositionsFromGridPosition(creaturePos, inDirection: creature.direction)

                for gridPosition in visibleGridPositions where pointEqualToPoint(gridPosition, point2: playerPos) {
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
    
    private func playerInRangeForMeleeAttack() -> Bool {
        var playerVisible = false
        
        if let creature = self.creature {
            let gridPosition = creature.gridPosition
            let direction = creature.direction
            
            var visibleGridPositions: [Point] = [gridPosition]
            
            if let nextGridPosition = game?.nextVisibleGridPositionFromGridPosition(gridPosition, inDirection: direction) {
                visibleGridPositions.append(nextGridPosition)
            }
            
            for visibleGridPosition in visibleGridPositions {
                if let player = game?.playerAtGridPosition(visibleGridPosition){
                    playerVisible = player.isControllable
                    
                    if playerVisible {
                        break
                    }
                }
            }
        }
        
        return playerVisible
    }
}