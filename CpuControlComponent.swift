//
//  CpuControlComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit

class CpuControlComponent: GKComponent {
    private var attackDelay: NSTimeInterval = -1.0
    
    private(set) weak var game: Game?
    
    private var creature: Creature? {
        return self.entity as! Creature?
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
                if let creature = self.entity as! Creature? {
                    if let configComponent = creature.componentForClass(ConfigComponent) {
                        self.attackDelay -= seconds
                        if self.attackDelay < 0 {
                            if let projectileName = configComponent.projectile {
                                if configComponent.creatureType == .Boss {
                                    creature.attack()
                                    launchProjectileToPlayer(projectileName, forCreature: creature)
                                    self.attackDelay = creature.abilityCooldown
                                } else if playerInRangeForRangedAttack() {
                                    creature.attack()
                                    launchProjectile(projectileName, forCreature: creature)
                                    self.attackDelay = creature.abilityCooldown
                                }
                            } else if playerInRangeForMeleeAttack() {
                                creature.attack()
                                self.attackDelay = creature.abilityCooldown
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func launchProjectileToPlayer(entityName: String, forCreature creature: Creature) {
        let playerPos = self.game!.player1!.gridPosition
        let gridPosition = creature.gridPosition
        
        let dx = playerPos.x - gridPosition.x
        let dy = playerPos.y - gridPosition.y
        
        let distance = sqrt(pow(Float(dx), 2) + pow(Float(dy), 2))
        let speed = CGFloat(unitLength)
        let factor = 1.0 / CGFloat(distance) * speed
        
        let force = CGVector(dx: CGFloat(dx) * factor, dy: CGFloat(dy) * factor)
        
        addProjectileWithName(entityName, toGame: self.game!, withForce: force, gridPosition: gridPosition, collidesWithBlocks: false)
    }
    
    private func launchProjectile(entityName: String, forCreature creature: Creature) {
        let gridPosition = creature.gridPosition

        var dx: CGFloat = 0.0
        var dy: CGFloat = 0.0
        let speed = CGFloat(unitLength)
        
        switch creature.direction {
        case .Up: dy = speed
        case .Down: dy = -speed
        case .Right: dx = speed
        case .Left: dx = -speed
        default: break
        }
        
        let force = CGVector(dx: dx, dy: dy)

        addProjectileWithName(entityName, toGame: self.game!, withForce: force, gridPosition: gridPosition)
    }

    private func addProjectileWithName(name: String, toGame game: Game, withForce force: CGVector, gridPosition: Point, collidesWithBlocks: Bool) {
        let propLoader = PropLoader(forGame: game)
        
        do {
            if let projectile = try propLoader.projectileWithName(name, gridPosition: gridPosition) {
                projectile.force = CGVector(dx: force.dx * projectile.speed, dy: force.dy * projectile.speed)
                
                if let visualComponent = projectile.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.position = positionForGridPosition(gridPosition)
                    
                    if !collidesWithBlocks {
                        // TODO: consider make this bitmask configurable through config file.
                        visualComponent.spriteNode.physicsBody?.contactTestBitMask = EntityCategory.Player
                        visualComponent.spriteNode.physicsBody?.collisionBitMask = EntityCategory.Player
                    }
                }
                
                self.game?.addEntity(projectile)
            }
        } catch let error {
            print("error: \(error)")
        }
    }
    
    private func addProjectileWithName(name: String, toGame game: Game, withForce force: CGVector, gridPosition: Point) {
        addProjectileWithName(name, toGame: game, withForce: force, gridPosition: gridPosition, collidesWithBlocks: false)
    }

    private func playerInRangeForMeleeAttack() -> Bool {
        var playerVisible = false
        
        if let creature = self.creature {
            let gridPosition = creature.gridPosition
            let direction = creature.direction
            
            var visibleGridPositions: [Point] = [gridPosition]
            
            if let nextGridPosition = self.game?.nextVisibleGridPositionFromGridPosition(gridPosition, inDirection: direction) {
                visibleGridPositions.append(nextGridPosition)
            }
            
            for visibleGridPosition in visibleGridPositions {
                if let player = self.game?.playerAtGridPosition(visibleGridPosition){
                    playerVisible = player.isControllable
                    
                    if playerVisible {
                        break
                    }
                }
            }
        }
        
        return playerVisible
    }
    
    private func playerInRangeForRangedAttack() -> Bool {
        var playerVisible = false
        
        if let creature = self.creature {
            let gridPosition = creature.gridPosition
            let direction = creature.direction
            
            if let visibleGridPositions = self.game?.visibleGridPositionsFromGridPosition(gridPosition, inDirection: direction) {
                for visibleGridPosition in visibleGridPositions {
                    if let player = self.game?.playerAtGridPosition(visibleGridPosition) {
                        playerVisible = player.isControllable
                        
                        if playerVisible {
                            break                        
                        }
                    }
                }
            }
        }
        
        return playerVisible
    }
}