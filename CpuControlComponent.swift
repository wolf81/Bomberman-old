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
            if stateMachineComponent.currentState == nil {
                stateMachineComponent.enterRoamState()
            } else {
                if let creature = self.entity as! Creature? {
                    self.attackDelay -= seconds
                    
                    if self.attackDelay < 0 {
                        if let configComponent = self.entity?.componentForClass(ConfigComponent) {
                            if let projectileName = configComponent.projectile {
                                if playerInRangeForRangedAttack() {
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
    
    private func launchProjectile(entityName: String, forCreature creature: Creature) {
        let gridPosition = creature.gridPosition
        let direction = creature.direction

        let propLoader = PropLoader(forGame: self.game!)
        
        do {
            if let projectile = try propLoader.projectileWithName(entityName, gridPosition: gridPosition) {
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
                    if let player = self.game?.playerAtGridPosition(visibleGridPosition){
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