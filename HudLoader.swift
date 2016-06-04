//
//  HudLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class HudLoader {
    private(set) var heartSprites: [SKTexture]

    init() {
        let heartsTexture = SKTexture(imageNamed: "Heart Icons.png")
        let spriteSize = CGSize(width: 17, height: 18)
        self.heartSprites = SpriteLoader.spritesFromTexture(heartsTexture, withSpriteSize: spriteSize)
    }

}