//
//  Power.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/05/16.
//
//

import SpriteKit

enum PowerType {
    case MoveSpeed
    case BombExtra
    case BombSpeed
    case ExplosionRange
    case Heal
    case BonusHealth
    case Shield
    case Skull
    case Lightning
}

class Power: Prop {
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, type: PowerType) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
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
        let index = spriteIndex(forPower: type)
        let sprite = sprites[index]
        let visualComponent = VisualComponent(sprites: [sprite], createPhysicsBody: false)
        visualComponent.spriteNode.speed = configComponent.speed
        
        visualComponent.spriteNode.zPosition = 15
        
        addComponent(visualComponent)
    }
    
    // MARK: - Private
    
    private func spriteIndex(forPower power: PowerType) -> Int {
        var spriteIndex: Int
        
        switch power {
        case .BonusHealth: spriteIndex = 5
        case .BombExtra: fallthrough
        case .BombSpeed: fallthrough
        default: spriteIndex = 0
        }
        
        return spriteIndex
    }
}