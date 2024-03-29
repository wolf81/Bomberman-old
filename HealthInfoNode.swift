//
//  HealthNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class HealthInfoNode: SKShapeNode {
    fileprivate var heartNodes = [SKSpriteNode]()
    
    init(size: CGSize) {
        super.init()
        
        updateHealth(8)

        path = CGPath(rect: CGRect(origin: CGPoint.zero, size: size), transform: nil)

        isAntialiased = false
        lineWidth = 0
        blendMode = .replace
        zPosition = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateHealth(_ health: Int) {
        var fullHearts = health / 2
        var halfHearts = health - fullHearts
        
        if health < 16 {
            fullHearts = health / 2
            halfHearts = health % 2
        }
        
        for heartNode in heartNodes {
            heartNode.removeFromParent()
        }
        heartNodes.removeAll()
        
        let heartSize = CGSize(width: 40, height: 40)
        
        let hudLoader = HudLoader()
        let heartSprites = hudLoader.heartSprites
        
        for y in (0 ..< 2).reversed() {
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
                heartNode.anchorPoint = CGPoint.zero
                heartNodes.append(heartNode)
            }
        }
        
        heartNodes.forEach { heartNode in addChild(heartNode) }
    }
}
