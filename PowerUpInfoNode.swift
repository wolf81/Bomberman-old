//
//  AbilityInfoNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class PowerUpInfoNode: SKShapeNode {
    init(size: CGSize) {
        super.init()
                
        self.path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)
        
        self.antialiased = false
        self.lineWidth = 4
        self.strokeColor = SKColor.redColor()
        self.fillColor = SKColor.purpleColor()

        self.zPosition = 20
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}