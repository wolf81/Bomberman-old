//
//  Bomb.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/04/16.
//
//

import Foundation

class Bomb: Entity {
    var range: Int = 2
    let player: PlayerIndex
    
    // MARK: - Initialization
    
    init(forGame game: Game, player: PlayerIndex, configComponent: ConfigComponent, gridPosition: Point) {
        self.player = player
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = EntityLayer.Bomb.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = propCategory
                physicsBody.contactTestBitMask = nothingCategory
                physicsBody.collisionBitMask = nothingCategory
            }
        }
    }
    
    // MARK: - Public
    
    override func destroy() {
        super.destroy()
    }
    
    func explodeAtGridPosition(gridPosition: Point) throws {
        var validPositions: [(Point, Direction)] = [(gridPosition, .None)]
        
        // west
        for x in (gridPosition.x - self.range ..< gridPosition.x).reverse() {
            let testGridPosition = Point(x: x, y: gridPosition.y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.DestructableBlock &&
                    x == gridPosition.x - 1 {
                    validPositions.append((testGridPosition, .Left))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .Left))
            }
        }
        
        // east
        for x in (gridPosition.x + 1 ... gridPosition.x + self.range) {
            let testGridPosition = Point(x: x, y: gridPosition.y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.DestructableBlock &&
                    x == gridPosition.x + 1 {
                    validPositions.append((testGridPosition, .Right))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .Right))
            }
        }
        
        // north
        for y in (gridPosition.y + 1 ... gridPosition.y + self.range) {
            let testGridPosition = Point(x: gridPosition.x, y: y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.DestructableBlock &&
                    y == gridPosition.y + 1 {
                    validPositions.append((testGridPosition, .Up))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .Up))
            }
        }
        
        // south
        for y in (gridPosition.y - self.range ..< gridPosition.y).reverse() {
            let testGridPosition = Point(x: gridPosition.x, y: y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.DestructableBlock &&
                    y == gridPosition.y - 1 {
                    validPositions.append((testGridPosition, .Down))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .Down))
            }
        }
        
        for validPosition in validPositions {
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