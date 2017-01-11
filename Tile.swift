//
//  Tile.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit
import SpriteKit

class Tile : Entity {
    let tileType: TileType
    
    // MARK: - Initialization

    convenience init(gridPosition: Point, configComponent: ConfigComponent, tileType: TileType) {
        // TODO: make more safe, currently will crash if no config exists.
        let basePath = configComponent.configFilePath
        let filePath = basePath.stringByAppendingPathComponent(configComponent.textureFile)
        let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath))
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

        visualComponent.spriteNode.zPosition = EntityLayer.tile.rawValue

        let category = (tileType == .wall) ? EntityCategory.Wall : EntityCategory.Block
        
        if let physicsBody = visualComponent.spriteNode.physicsBody {
            physicsBody.categoryBitMask = category
            physicsBody.collisionBitMask = EntityCategory.Nothing
            physicsBody.contactTestBitMask = EntityCategory.Nothing
        }
        
        self.gridPosition = gridPosition
        self.value = PointsType.fifty
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func destroy() {
        removePhysicsBody()
        
        super.destroy()
    }
}
