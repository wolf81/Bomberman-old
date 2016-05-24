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
    let tileType: TileType
    
    convenience init(gridPosition: Point, configComponent: ConfigComponent, tileType: TileType) {
        // TODO: make more safe, currently will crash if no config exists.
        let basePath = configComponent.configFilePath!
        let filePath = basePath.stringByAppendingPathComponent(configComponent.textureFile)
        let imageData = NSData(contentsOfFile: filePath)
        let image = Image(data: imageData!)
        let texture = SKTexture(image: image!)
        
        let sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: configComponent.spriteSize)
        let visualComponent = VisualComponent(sprites: sprites)        
        
        self.init(gridPosition: gridPosition, visualComponent: visualComponent, tileType: tileType)
        
        addComponent(configComponent)
    }
    
    init(gridPosition: Point, visualComponent: VisualComponent, tileType: TileType) {
        self.tileType = tileType

        super.init(visualComponent: visualComponent)

        visualComponent.spriteNode.zPosition = 20

        if let physicsBody = visualComponent.spriteNode.physicsBody {
            physicsBody.categoryBitMask = tileCategory
            physicsBody.collisionBitMask = nothingCategory
            physicsBody.contactTestBitMask = nothingCategory
        }
        
        self.gridPosition = gridPosition
    }
}