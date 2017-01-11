//
//  Creature.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit
import SpriteKit

class Creature: Entity {
    var health: Int = 1
    var lives: Int = 1
    var name: String?
    
    // Used by monsters as shooting delay, for players as refill time for bombs.
    let abilityCooldown: TimeInterval = 2.0
        
    fileprivate(set) var nextGridPosition = Point(x: 0, y: 0)
    
    var isMoving: Bool {
        var isMoving = false
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            // TODO: check for explicit animation action, cause just sounds are also possible
            isMoving = visualComponent.spriteNode.hasActions()
        }
        
        return isMoving
    }
    
    var position: CGPoint {
        var position = positionForGridPosition(gridPosition)
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            position = visualComponent.spriteNode.position
        }
        
        return position
    }
    
    // MARK: - Initialization 
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        lives = configComponent.lives
        health = configComponent.health
        
        let url = URL(fileURLWithPath: configComponent.configFilePath)
        self.name = url.lastPathComponent
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func movementDirectionsFromCurrentGridPosition() -> [(direction: Direction, gridPosition: Point)] {
        var directions = [(direction: Direction, gridPosition: Point)]()
        
        if let game = self.game {
            let upGridPosition = Point(x: gridPosition.x, y: gridPosition.y + 1)
            if canMoveToGridPosition(upGridPosition, forGame: game) {
                directions.append((.up, upGridPosition))
            }

            let leftGridPosition = Point(x: gridPosition.x - 1, y: gridPosition.y)
            if canMoveToGridPosition(leftGridPosition, forGame: game) {
                directions.append((.left, leftGridPosition))                
            }
            
            let downGridPosition = Point(x: gridPosition.x, y: gridPosition.y - 1)
            if canMoveToGridPosition(downGridPosition, forGame: game) {
                directions.append((.down, downGridPosition))
            }
            
            let rightGridPosition = Point(x: gridPosition.x + 1, y: gridPosition.y)
            if canMoveToGridPosition(rightGridPosition, forGame: game) {
                directions.append((.right, rightGridPosition))
            }
        }
        
        return directions
    }
    
    func updateForDirection(_ direction: Direction) {
        // Can be overridden by subclasses. 
        //  Used by the Player subclass to update shield texture when movement direction changes.
    }
    
    func moveInDirection(_ direction: Direction) -> Bool {
        var didMove = false
        
        let validDirections = movementDirectionsFromCurrentGridPosition()
        if let validDirection = (validDirections.filter { $0.direction == direction }).first {
            if validDirection.direction != .none {
                moveToGridPosition(validDirection.gridPosition, direction: validDirection.direction, completion: nil)
                didMove = true
            }
        }
        
        return didMove
    }

    func moveInRandomDirection(_ completion: @escaping () -> Void) {
        var validDirections = movementDirectionsFromCurrentGridPosition()

        // Filter out any tiles a monster stands on or will move to (ignore players).
        validDirections = validDirections.filter { (direction, gridPosition) -> Bool in
            var canMove = true

            for creature in game!.creatures where creature is Monster {
                if pointEqualToPoint(creature.gridPosition, gridPosition) || pointEqualToPoint(creature.nextGridPosition, gridPosition) {
                    canMove = false
                }
            }
            
            return canMove
        }
        
        let count = validDirections.count
        if count > 0 {
            let randomIndex = Int(arc4random() % UInt32(count))
            let randomDirection = validDirections[randomIndex]
            
            moveToGridPosition(randomDirection.gridPosition, direction: randomDirection.direction, completion: completion)
        }
    }    
    
    override func hit(_ damage: Int) {
        if health <= 0 {
            destroy()
        } else {
            super.hit(damage)
        }
    }
    
    override func destroy() {
        if lives == 0 {
            removePhysicsBody()
        }
        
        super.destroy()
    }
        
    // MARK: - Private
    
    fileprivate func moveToGridPosition(_ gridPosition: Point, direction: Direction, completion: (() -> Void)?) {
        if let visualComponent = component(ofType: VisualComponent.self) {
            self.direction = direction
            self.nextGridPosition = gridPosition
            
            let location = positionForGridPosition(gridPosition)
            visualComponent.moveInDirection(direction, toPosition: location, completion: {
                self.gridPosition = gridPosition
                
                if let completionBlock = completion {
                    completionBlock()
                }
            })
        }
    }
    
    func stop() {
        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.removeAllActions()
            self.direction = .none
        }
    }
    
    func canMoveToGridPosition(_ gridPosition: Point, forGame game: Game) -> Bool {
        var canMove = false
        
        if game.bossAtGridPosition(gridPosition) == nil && game.tileAtGridPosition(gridPosition) == nil {
            canMove = true
        }
        
        return canMove
    }
}

