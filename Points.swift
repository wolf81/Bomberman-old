//
//  Points.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/05/16.
//
//

import SpriteKit

enum PointsType: Int {
    case Ten = 10
    case Fifty = 50
    case Hundred = 100
}

class Points: Entity {
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, type: PointsType) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: false)
        
        var texture: SKTexture
        
        // TODO: when game starts for first time, just copy files in bundle to assets directory
        //  and read from this location always. Or keep this code only for debug / devel purposes?
        if let basePath = configComponent.configFilePath {
            let filePath = basePath.stringByAppendingPathComponent(configComponent.textureFile)
            let imageData = NSData(contentsOfFile: filePath)
            let image = Image(data: imageData!)
            texture = SKTexture(image: image!)
        } else {
            texture = SKTexture(imageNamed: configComponent.textureFile)
        }
        
        let sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: configComponent.spriteSize)
        let index = spriteIndex(forPointsType: type)
        let sprite = sprites[index]
        let visualComponent = VisualComponent(sprites: [sprite], createPhysicsBody: false)
        visualComponent.spriteNode.speed = configComponent.speed
        
        visualComponent.spriteNode.zPosition = 80
        
        addComponent(visualComponent)
    }
    
    // MARK: - Private
    
    private func spriteIndex(forPointsType type: PointsType) -> Int {
        var spriteIndex: Int
        
        switch type {
        case .Ten: spriteIndex = 0
        case .Fifty: spriteIndex = 1
        case .Hundred: spriteIndex = 2
        }
        
        return spriteIndex
    }
}