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
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.zPosition = EntityLayer.bomb.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Prop
                physicsBody.contactTestBitMask = EntityCategory.Nothing
                physicsBody.collisionBitMask = EntityCategory.Nothing
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    override func destroy() {
        super.destroy()
    }
    
    func explodeAtGridPosition(_ gridPosition: Point) throws {
        var validPositions: [(Point, Direction)] = [(gridPosition, .none)]
        
        // west
        for x in (gridPosition.x - self.range ..< gridPosition.x).reversed() {
            let testGridPosition = Point(x: x, y: gridPosition.y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.destructableBlock &&
                    x == gridPosition.x - 1 {
                    validPositions.append((testGridPosition, .left))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .left))
            }
        }
        
        // east
        for x in (gridPosition.x + 1 ... gridPosition.x + self.range) {
            let testGridPosition = Point(x: x, y: gridPosition.y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.destructableBlock &&
                    x == gridPosition.x + 1 {
                    validPositions.append((testGridPosition, .right))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .right))
            }
        }
        
        // north
        for y in (gridPosition.y + 1 ... gridPosition.y + self.range) {
            let testGridPosition = Point(x: gridPosition.x, y: y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.destructableBlock &&
                    y == gridPosition.y + 1 {
                    validPositions.append((testGridPosition, .up))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .up))
            }
        }
        
        // south
        for y in (gridPosition.y - self.range ..< gridPosition.y).reversed() {
            let testGridPosition = Point(x: gridPosition.x, y: y)
            
            if let tile = self.game?.tileAtGridPosition(testGridPosition) {
                if tile.tileType == TileType.destructableBlock &&
                    y == gridPosition.y - 1 {
                    validPositions.append((testGridPosition, .down))
                    tile.destroy()
                }
                break
            } else {
                validPositions.append((testGridPosition, .down))
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
