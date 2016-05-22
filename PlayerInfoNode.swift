//
//  PlayerInfoNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 06/05/16.
//
//

import SpriteKit

class PlayerInfoNode: SKShapeNode {
    let nameNode = SKLabelNode()
    let healthNode = SKLabelNode()
    let livesNode = SKLabelNode()
    let scoreNode = SKLabelNode()
    
    init(size: CGSize, text: String) {
        super.init()
        
        let x = size.width / 2
        
        let yMargin: CGFloat = 10
        let rowHeight = (size.height - (yMargin * 2)) / 4
        
        self.nameNode.text = text
        self.nameNode.fontName = "TamilSangamMN-Bold"
        self.nameNode.fontSize = 35
        var y = size.height - yMargin
        self.nameNode.position = CGPoint(x: x, y: y)
        addChild(self.nameNode)
        
        self.livesNode.text = "Lives: 0"
        self.livesNode.fontName = "TamilSangamMN"
        self.livesNode.fontSize = 35
        y -= rowHeight
        self.livesNode.position = CGPoint(x: x, y: y)
        addChild(self.livesNode)
        
        self.healthNode.text = "Health: 0"
        self.healthNode.fontName = "TamilSangamMN"
        self.healthNode.fontSize = 35
        y -= rowHeight
        self.healthNode.position = CGPoint(x: x, y: y)
        addChild(self.healthNode)
        
        self.scoreNode.text = "Score: 0"
        y -= rowHeight
        self.scoreNode.position = CGPoint(x: x, y: y)
        self.scoreNode.fontName = "TamilSangamMN"
        self.scoreNode.fontSize = 35
        addChild(self.scoreNode)
        
        self.path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)

        self.antialiased = false
        self.lineWidth = 0
        self.blendMode = .Replace
    }
    
    func updateLives(lives: Int) {
        self.livesNode.text = String(format: "Lives: \(lives + 1)")
    }
    
    func updateHealth(health: Int) {
        var healthString = "Health: "
        
        for _ in 0 ..< health {
            healthString += "*"
        }

        self.healthNode.text = healthString
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
