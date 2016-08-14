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
                if let creature = self.entity as! Creature? {
                    if let configComponent = creature.componentForClass(ConfigComponent) {
                        attackDelay -= seconds
                        
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
    
    private func distanceBetweenPoint(point: Point, otherPoint: Point) -> (distance: CGFloat, dx: CGFloat, dy: CGFloat) {
        let dx = CGFloat(point.x - otherPoint.x)
        let dy = CGFloat(point.y - otherPoint.y)
        let distance = hypot(dx, dy)
        
        return (distance, dx, dy)
    }
    
    private func launchProjectileToPlayer(entityName: String, forCreature creature: Creature, direction: AttackDirection) -> Bool {
        var didAttack = false
        
        let players = [game?.player1, game?.player2].flatMap{ $0 }
        var distance: CGFloat = CGFloat.max
        let creaturePos = creature.gridPosition
        var offset: (dx: CGFloat, dy: CGFloat) = (dx: 0, dy: 0)

        switch direction {
        case .Any:
            for testPlayer in players {
                let result = distanceBetweenPoint(testPlayer.gridPosition, otherPoint: creature.gridPosition)
                if result.distance < distance {
                    distance = result.distance
                    offset = (dx: result.dx, dy: result.dy)
                }
            }
            
            let speed = CGFloat(unitLength)
            let factor = 1.0 / CGFloat(distance) * speed
            let force = CGVector(dx: offset.dx * factor, dy: offset.dy * factor)
            
            addProjectileWithName(entityName, toGame: game!, withForce: force, gridPosition: creaturePos)
            
            didAttack = true
        case .Axial:
            var playerPos = players.first!.gridPosition
            
            for testPlayer in players {
                let result = distanceBetweenPoint(testPlayer.gridPosition, otherPoint: creature.gridPosition)
                if result.distance < distance {
                    playerPos = testPlayer.gridPosition
                    distance = result.distance
                    offset = (dx: result.dx, dy: result.dy)
                }
            }
            
            if offset.dx == 0 || offset.dy == 0 {
                let visibleGridPositions = game!.visibleGridPositionsFromGridPosition(creaturePos, inDirection: creature.direction)

                for gridPosition in visibleGridPositions where pointEqualToPoint(gridPosition, point2: playerPos) {
                    let speed = CGFloat(unitLength)
                    let factor = 1.0 / CGFloat(distance) * speed
                    let force = CGVector(dx: offset.dx * factor, dy: offset.dy * factor)
                    
                    addProjectileWithName(entityName, toGame: game!, withForce: force, gridPosition: creaturePos)
                    
                    didAttack = true
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