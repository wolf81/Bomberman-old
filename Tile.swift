//
//  Tile.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit
import SpriteKit

class Tile: Entity {
    var tileType = TileType.None
    
    convenience init(gridPosition: Point, configComponent: ConfigComponent) {
        let texture = SKTexture(imageNamed: configComponent.textureFile)
        let sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: configComponent.spriteSize)
        let visualComponent = VisualComponent(sprites: sprites)
        
        visualComponent.spriteNode.zPosition = 20
        
        self.init(gridPosition: gridPosition, visualComponent: visualComponent)
        
        addComponent(configComponent)
                        
        self.gridPosition = gridPosition
    }
    
    init(gridPosition: Point, visualComponent: VisualComponent) {        
        super.init(visualComponent: visualComponent)
        
        if let physicsBody = visualComponent.spriteNode.physicsBody {
            physicsBody.categoryBitMask = tileCategory
            physicsBody.collisionBitMask = 0
        }
        
        self.gridPosition = gridPosition
    }
}