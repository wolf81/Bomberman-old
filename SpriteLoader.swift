//
//  SpriteLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation
import SpriteKit

class SpriteLoader {
    static func spritesFromTexture(_ spritesTexture: SKTexture,
                                   withSpriteSize spriteSize: CGSize) -> [SKTexture] {
        var textures = [SKTexture]()

        let textureHeight = spritesTexture.size().height
        let textureWidth = spritesTexture.size().width

        let spriteWidth = spriteSize.width / textureWidth
        let spriteHeight = spriteSize.height / textureHeight
        
        var yOffset: CGFloat = 1.0
        
        for _ in stride(from: Int(textureHeight), to: 0, by: Int(-spriteSize.height)) {
            yOffset -= spriteHeight

            for x in stride(from: 0, to: Int(textureWidth), by: Int(spriteSize.width)) {
                let xOffset = CGFloat(x) / textureWidth
                
                let rect = CGRect(x: xOffset, y: yOffset, width: spriteWidth, height: spriteHeight)
                let texture = SKTexture(rect: rect, in: spritesTexture)
                textures.append(texture)
            }
        }
        
        return textures
    }
}
