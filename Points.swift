//
//  Points.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/05/16.
//
//

import SpriteKit

enum PointsType: Int {
    case ten = 10
    case fifty = 50
    case hundred = 100
}

class Points: Entity {
    
    // MARK: - Initialization

    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, type: PointsType) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: false)
        
        var texture: SKTexture
        
        // TODO: when game starts for first time, just copy files in bundle to assets directory
        //  and read from this location always. Or keep this code only for debug / devel purposes?
        let filePath = configComponent.configFilePath.stringByAppendingPathComponent(configComponent.textureFile)
        let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        let image = Image(data: imageData!)
        texture = SKTexture(image: image!)
        
        let sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: configComponent.spriteSize)
        let index = spriteIndex(forPointsType: type)
        let sprite = sprites[index]
        let visualComponent = VisualComponent(sprites: [sprite], createPhysicsBody: false)
        visualComponent.spriteNode.speed = configComponent.speed
        
        visualComponent.spriteNode.zPosition = EntityLayer.points.rawValue
        
        addComponent(visualComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    fileprivate func spriteIndex(forPointsType type: PointsType) -> Int {
        var spriteIndex: Int
        
        switch type {
        case .ten: spriteIndex = 0
        case .fifty: spriteIndex = 1
        case .hundred: spriteIndex = 2
        }
        
        return spriteIndex
    }
}
