//
//  PlayerInfoNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 06/05/16.
//
//

import SpriteKit

class PlayerInfoNode: SKShapeNode {
    let headNode: SKSpriteNode
    let healthNode = SKLabelNode()
    let livesNode = SKLabelNode()
    let scoreTitleNode = SKLabelNode()
    let scoreValueNode = SKLabelNode()
    
    init(size: CGSize, text: String) {
        let headTexture = SKTexture(imageNamed: "Player 1 Head.png")
        self.headNode = SKSpriteNode(texture: headTexture, color: SKColor.purpleColor(), size: headTexture.size())
        
        super.init()
        
        self.path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)
        
        let x = size.width / 2
        
        let yMargin: CGFloat = 10
        let rowHeight = (size.height - (yMargin * 2)) / 4
        
        headNode.position = CGPoint(x: 80, y: size.height - 45)
        self.addChild(headNode)
        
        self.livesNode.text = "Lives: 0"
        self.livesNode.fontName = "TamilSangamMN"
        self.livesNode.fontSize = 35
        var y = size.height - yMargin
        self.livesNode.position = CGPoint(x: 140, y: size.height - 55)
        addChild(self.livesNode)
        
        self.healthNode.text = "Health: 0"
        self.healthNode.fontName = "TamilSangamMN"
        self.healthNode.fontSize = 35
        y -= rowHeight
        self.healthNode.position = CGPoint(x: x, y: y)
        addChild(self.healthNode)
        
        self.scoreTitleNode.text = "SCORE"
        self.scoreTitleNode.position = CGPoint(x: x, y: 65)
        self.scoreTitleNode.fontName = "TamilSangamMN"
        self.scoreTitleNode.fontSize = 35
        addChild(self.scoreTitleNode)

        self.scoreValueNode.text = "000000"
        self.scoreValueNode.position = CGPoint(x: x, y: 25)
        self.scoreValueNode.fontName = "TamilSangamMN"
        self.scoreValueNode.fontSize = 35
        addChild(self.scoreValueNode)
        
        self.antialiased = false
        self.lineWidth = 4
        self.strokeColor = SKColor.redColor()
        self.fillColor = SKColor.blueColor()
        self.blendMode = .Add
        
        self.zPosition = 15
    }
    
    func updateLives(lives: Int) {
        self.livesNode.text = String(format: "x\(lives + 1)")
    }
    
    func updateHealth(health: Int) {
        var healthString = "Health: "
        
        for _ in 0 ..< health {
            healthString += "*"
        }

        self.healthNode.text = healthString
    }
    
    required init?(coder aDecoder: NSCoder) {
        let headTexture = SKTexture(imageNamed: "Player 1 Head.png")
        self.headNode = SKSpriteNode(texture: headTexture, color: SKColor.purpleColor(), size: headTexture.size())

        super.init(coder: aDecoder)
    }
}
