//
//  Bomb.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/04/16.
//
//

import Foundation

class Bomb: Entity {
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = 60
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = propCategory
                physicsBody.contactTestBitMask = nothingCategory
                physicsBody.collisionBitMask = nothingCategory
            }
        }
    }
    
    func explodeAtGridPosition(gridPosition: Point) throws {
        let range = 3
        
        var validPositions: [(Point, Direction)] = [(gridPosition, .None)]
        
        // west
        for x in (gridPosition.x - range ..< gridPosition.x).reverse() {
            let testGridPosition = Point(x: x, y: gridPosition.y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.DestructableBlock &&
                    x == gridPosition.x - 1 {
                    validPositions.append((testGridPosition, .West))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .West))
            }
        }
        
        // east
        for x in (gridPosition.x + 1 ... gridPosition.x + range) {
            let testGridPosition = Point(x: x, y: gridPosition.y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.DestructableBlock &&
                    x == gridPosition.x + 1 {
                    validPositions.append((testGridPosition, .East))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .East))
            }
        }
        
        // north
        for y in (gridPosition.y + 1 ... gridPosition.y + range) {
            let testGridPosition = Point(x: gridPosition.x, y: y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.DestructableBlock &&
                    y == gridPosition.y + 1 {
                    validPositions.append((testGridPosition, .North))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .North))
            }
        }
        
        // south
        for y in (gridPosition.y - range ..< gridPosition.y).reverse() {
            let testGridPosition = Point(x: gridPosition.x, y: y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.DestructableBlock &&
                    y == gridPosition.y - 1 {
                    validPositions.append((testGridPosition, .South))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .South))
            }
        }
        
        for validPosition in validPositions {
            if let creature = self.game?.creatureAtGridPosition(validPosition.0) {
                print("destroy: \(creature)")
                creature.destroy()
            }
            
            if let bomb = self.game?.bombAtGridPosition(validPosition.0) {
                bomb.destroy()
            }
            
            let propLoader = PropLoader(forGame: self.game!)
            if let explosion = try propLoader.explosionWithGridPosition(validPosition.0,
                                                                    direction: validPosition.1) {
                self.game?.addEntity(explosion)
            }
        }
    }
}