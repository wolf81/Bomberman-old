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
            
            let northGridPosition = Point(x: gridPosition.x, y: gridPosition.y + 1)
            if let tile = game.tileAtGridPosition(northGridPosition) {
                if tile.isDestroyed {
                    directions.append((.North, northGridPosition))
                }
            } else {
                directions.append((.North, northGridPosition))
            }
            
            let westGridPosition = Point(x: gridPosition.x - 1, y: gridPosition.y)
            if let tile = game.tileAtGridPosition(westGridPosition) {
                if tile.isDestroyed {
                    directions.append((.West, westGridPosition))
                }
            } else {
                directions.append((.West, westGridPosition))
            }
            
            let southGridPosition = Point(x: gridPosition.x, y: gridPosition.y - 1)
            if let tile = game.tileAtGridPosition(southGridPosition) {
                if tile.isDestroyed {
                    directions.append((.South, southGridPosition))
                }
            } else {
                directions.append((.South, southGridPosition))
            }
            
            let eastGridPosition = Point(x: gridPosition.x + 1, y: gridPosition.y)
            if let tile = game.tileAtGridPosition(eastGridPosition) {
                if tile.isDestroyed {
                    directions.append((.East, eastGridPosition))
                }
            } else {
                directions.append((.East, eastGridPosition))            
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
    
    override func hit() {
        if self.health <= 0 {
            destroy()
        } else {
            super.hit()
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
}

