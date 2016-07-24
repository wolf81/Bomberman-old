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
        let playerPos = self.game!.player1?.position
        let gridPosition = creature.gridPosition
        
//        let dx: CGFloat = creaturePos / playerPos
        let velocity = CGVector(dx: 0.4, dy: 1.2)
     
        let propLoader = PropLoader(forGame: self.game!)
        
        do {
            if let projectile = try propLoader.projectileWithName(entityName, gridPosition: gridPosition) {
                if let visualComponent = projectile.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.position = creature.position
                    visualComponent.spriteNode.physicsBody?.velocity = velocity
                }
                
                self.game?.addEntity(projectile)
            }
        } catch let error {
            print("error: \(error)")
        }
    }
    
    private func launchProjectile(entityName: String, forCreature creature: Creature) {
        let gridPosition = creature.gridPosition
        let direction = creature.direction

        let propLoader = PropLoader(forGame: self.game!)
        
        do {
            if let projectile = try propLoader.projectileWithName(entityName, gridPosition: gridPosition) {
                if let visualComponent = projectile.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.position = creature.position
                }
                 
                projectile.direction = direction
                
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