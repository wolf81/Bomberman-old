//
//  HudLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class HudLoader {
    fileprivate(set) var heartSprites: [SKTexture]
    fileprivate(set) var powerUpSprites: [SKTexture]

    init() {
        let heartsTexture = SKTexture(imageNamed: "Heart Icons.png")
        let heartsSpriteSize = CGSize(width: 17, height: 18)
        self.heartSprites = SpriteLoader.spritesFromTexture(heartsTexture,
                                                            withSpriteSize: heartsSpriteSize)
        
        let powerUpsTexture = SKTexture(imageNamed: "Bonus Icons.png")
        let powerUpsSpriteSize = CGSize(width: 14, height: 14)
        self.powerUpSprites = SpriteLoader.spritesFromTexture(powerUpsTexture,
                                                              withSpriteSize: powerUpsSpriteSize)
    }

}
