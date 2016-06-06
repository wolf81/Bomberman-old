//
//  HealthNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class HealthInfoNode: SKShapeNode {
    private var heartNodes = [SKSpriteNode]()
    
    init(size: CGSize) {
        super.init()
        
        updateHealth(8)

        self.path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)

        self.antialiased = false
        self.lineWidth = 0
        self.blendMode = .Replace
        
        self.zPosition = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateHealth(health: Int) {
        var fullHearts = health / 2
        var halfHearts = health - fullHearts
        
        if health < 16 {
            fullHearts = health / 2
            halfHearts = health % 2
        }
        
        for heartNode in self.heartNodes {
            heartNode.removeFromParent()
        }
        self.heartNodes.removeAll()
        
        let heartSize = CGSize(width: 40, height: 40)
        
        let hudLoader = HudLoader()
        let heartSprites = hudLoader.heartSprites
        
        for y in (0 ..< 2).reverse() {
            for x in 0 ..< 4 {
                var heartSprite: SKTexture
                
                if fullHearts > 0 {
                    heartSprite = heartSprites[2]
                    fullHearts -= 1
                } else if halfHearts > 0 {
                    heartSprite = heartSprites[1]
                    halfHearts -= 1
                } else {
                    heartSprite = heartSprites[0]
                }
                
                let xPos = x * Int(heartSize.width + 0) + 25
                let yPos = (y * Int(heartSize.height + 5)) + 15
                let heartNode = SKSpriteNode(texture: heartSprite, size: heartSize)
                heartNode.position = CGPoint(x: xPos, y: yPos)
                heartNode.anchorPoint = CGPointZero
                self.heartNodes.append(heartNode)
            }
        }
        
        for heartNode in self.heartNodes {
            self.addChild(heartNode)
        }
    }
}