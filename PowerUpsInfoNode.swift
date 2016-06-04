//
//  AbilityInfoNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class PowerUpsInfoNode: SKShapeNode {
    private var powerUpNodes = [SKSpriteNode]()

    init(size: CGSize) {
        super.init()
                
        self.path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)
        
        self.antialiased = false
        self.lineWidth = 0
        self.fillColor = SKColor.purpleColor()

        self.zPosition = 20
        
        updateAbilities()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateAbilities() {
        let powerUpSize = CGSize(width: 30, height: 30)
        
        let hudLoader = HudLoader()
        let powerUpSprites = hudLoader.powerUpSprites
        
        for i in (0 ..< 5).reverse() {
            var powerUpSprite: SKTexture
            powerUpSprite = powerUpSprites[i + 6]

            let xPos = i * Int(powerUpSize.width) + 25
            let yPos = 45
            let powerUpNode = SKSpriteNode(texture: powerUpSprite, size: powerUpSize)
            powerUpNode.position = CGPoint(x: xPos, y: yPos)
            powerUpNode.anchorPoint = CGPointZero
            self.powerUpNodes.append(powerUpNode)
        }

        for powerUpNode in self.powerUpNodes {
            self.addChild(powerUpNode)
        }
    }
}