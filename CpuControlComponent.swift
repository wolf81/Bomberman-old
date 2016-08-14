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
                                if launchProjectileToPlayer(projectileName, forCreature: creature, direction: configComponent.attackDirection) {
                                    creature.attack()
                                    
                                    attackDelay = creature.abilityCooldown
                                }
                            } else if playerInRangeForMeleeAttack() {
                                creature.attack()
                                attackDelay = creature.abilityCooldown
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func launchProjectileToPlayer(entityName: String, forCreature creature: Creature, direction: AttackDirection) -> Bool {
        var didAttack = false
        
        switch direction {
        case .Any:
            let players = [self.game?.player1, self.game?.player2].flatMap{ $0 }
            var distance: CGFloat = CGFloat.max
            let creaturePos = creature.gridPosition
            var offset: (dx: CGFloat, dy: CGFloat) = (dx: 0, dy: 0)
            
            for testPlayer in players {
                let dx = CGFloat(testPlayer.gridPosition.x - creaturePos.x)
                let dy = CGFloat(testPlayer.gridPosition.y - creaturePos.y)
                let playerDistance = hypot(dx, dy)
                
                if playerDistance < distance {
                    distance = playerDistance
                    offset = (dx: dx, dy: dy)
                }
            }
            
            let speed = CGFloat(unitLength)
            let factor = 1.0 / CGFloat(distance) * speed
            let force = CGVector(dx: offset.dx * factor, dy: offset.dy * factor)
            
            addProjectileWithName(entityName, toGame: self.game!, withForce: force, gridPosition: creaturePos)
            
            didAttack = true
        case .Axial:
            let players = [self.game?.player1, self.game?.player2].flatMap{ $0 }
            var distance: CGFloat = CGFloat.max
            let creaturePos = creature.gridPosition
            var playerPos = players.first!.gridPosition
            var offset: (dx: CGFloat, dy: CGFloat) = (dx: 0, dy: 0)
            
            for testPlayer in players {
                let dx = CGFloat(testPlayer.gridPosition.x - creaturePos.x)
                let dy = CGFloat(testPlayer.gridPosition.y - creaturePos.y)
                let playerDistance = hypot(dx, dy)
                
                if playerDistance < distance {
                    playerPos = testPlayer.gridPosition
                    distance = playerDistance
                    offset = (dx: dx, dy: dy)
                }
            }
            
            if offset.dx == 0 || offset.dy == 0 {
                let visibleGridPositions = self.game!.visibleGridPositionsFromGridPosition(creaturePos, inDirection: creature.direction)

                for gridPosition in visibleGridPositions {
                    if pointEqualToPoint(gridPosition, point2: playerPos) {
                        let speed = CGFloat(unitLength)
                        let factor = 1.0 / CGFloat(distance) * speed
                        let force = CGVector(dx: offset.dx * factor, dy: offset.dy * factor)
                        
                        addProjectileWithName(entityName, toGame: self.game!, withForce: force, gridPosition: creaturePos)
                        
                        didAttack = true
                    }
                }
            }
        }
        
        return didAttack
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
}