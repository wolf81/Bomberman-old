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

    private(set) var direction = Direction.None
    private(set) var nextGridPosition = Point(x: 0, y: 0)
    
    var isMoving: Bool {
        var isMoving = false
        
        if let visualComponent = componentForClass(VisualComponent) {
            // TODO: check for explicit animation action, cause just sounds are also possible
            isMoving = visualComponent.spriteNode.hasActions()
        }
        
        return isMoving
    }
    
    override init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        self.lives = configComponent.lives
        self.health = configComponent.health
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
    }
    
    private func moveToGridPosition(gridPosition: Point, direction: Direction) {
        if let visualComponent = componentForClass(VisualComponent) {
            self.direction = direction            
            self.nextGridPosition = gridPosition
            
            let location = game!.positionForGridPosition(gridPosition)
            visualComponent.moveInDirection(direction, toPosition: location, completion: {
                self.gridPosition = gridPosition
            })
        }
    }
    
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
    
    func dropBomb() {
        if let game = self.game {
            let propLoader = PropLoader(forGame: game)
            if let position = self.componentForClass(VisualComponent)?.spriteNode.position {
                let gridPosition = game.gridPositionForPosition(position)
                
                if game.bombAtGridPosition(gridPosition) == nil {
                    do {
                        if let bomb = try propLoader.bombWithGridPosition(gridPosition) {
                            game.addEntity(bomb)
                        }
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            }
        }
    }
}

