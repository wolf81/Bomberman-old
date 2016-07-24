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
    
    // Used by monsters as shooting delay, for players as refill time for bombs.
    let abilityCooldown: NSTimeInterval = 2.0
        
    private(set) var nextGridPosition = Point(x: 0, y: 0)
    
    var isMoving: Bool {
        var isMoving = false
        
        if let visualComponent = componentForClass(VisualComponent) {
            // TODO: check for explicit animation action, cause just sounds are also possible
            isMoving = visualComponent.spriteNode.hasActions()
        }
        
        return isMoving
    }
    
    var position: CGPoint {
        var position = positionForGridPosition(self.gridPosition)
        
        if let visualComponent = componentForClass(VisualComponent) {
            position = visualComponent.spriteNode.position
        }
        
        return position
    }
    
    // MARK: - Initialization 
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        self.lives = configComponent.lives
        self.health = configComponent.health
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
    }
    
    // MARK: - Public
    
    func movementDirectionsFromCurrentGridPosition() -> [(direction: Direction, gridPosition: Point)] {
        var directions = [(direction: Direction, gridPosition: Point)]()
        
        if let game = self.game {
            let gridPosition = self.gridPosition
            
            let upGridPosition = Point(x: gridPosition.x, y: gridPosition.y + 1)
            if canMoveToGridPosition(upGridPosition, forGame: game) {
                directions.append((.Up, upGridPosition))
            }

            let leftGridPosition = Point(x: gridPosition.x - 1, y: gridPosition.y)
            if canMoveToGridPosition(leftGridPosition, forGame: game) {
                directions.append((.Left, leftGridPosition))
            }
            
            let downGridPosition = Point(x: gridPosition.x, y: gridPosition.y - 1)
            if canMoveToGridPosition(downGridPosition, forGame: game) {
                directions.append((.Down, downGridPosition))
            }
            
            let rightGridPosition = Point(x: gridPosition.x + 1, y: gridPosition.y)
            if canMoveToGridPosition(rightGridPosition, forGame: game) {
                directions.append((.Right, rightGridPosition))
            }
        }
        
        return directions
    }
    
    func updateForDirection(direction: Direction) {
        // Can be overridden by subclasses. 
        //  Used by the Player subclass to update shield texture when movement direction changes.
    }
    
    func moveInDirection(direction: Direction) -> Bool {
        var didMove = false
        
        let validDirections = movementDirectionsFromCurrentGridPosition()
        if let validDirection = (validDirections.filter { $0.direction == direction }).first {
            if validDirection.direction != .None {
                moveToGridPosition(validDirection.gridPosition, direction: validDirection.direction)
                didMove = true
            }
        }
        
        return didMove
    }

    func moveInRandomDirection() {
        let validDirections = movementDirectionsFromCurrentGridPosition()
        
        let count = validDirections.count
        if count > 0 {
            let randomIndex = Int(arc4random() % UInt32(count))
            let randomDirection = validDirections[randomIndex]
            moveToGridPosition(randomDirection.gridPosition, direction: randomDirection.direction)
        }
    }    
    
    override func hit(damage: Int) {
        if self.health <= 0 {
            destroy()
        } else {
            super.hit(damage)
        }
    }
    
    // MARK: - Private
    
    private func moveToGridPosition(gridPosition: Point, direction: Direction) {
        if let visualComponent = componentForClass(VisualComponent) {
            self.direction = direction
            self.nextGridPosition = gridPosition
            
            let location = positionForGridPosition(gridPosition)
            visualComponent.moveInDirection(direction, toPosition: location, completion: {
                self.gridPosition = gridPosition
            })
        }
    }
    
    func canMoveToGridPosition(gridPosition: Point, forGame game: Game) -> Bool {
        var canMove = false
        
        if game.bossAtGridPosition(gridPosition) == nil && game.tileAtGridPosition(gridPosition) == nil {
            canMove = true
        }
        
        return canMove
    }
}

