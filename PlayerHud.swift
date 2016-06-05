//
//  PlayerInfoNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 06/05/16.
//
//

import SpriteKit

class PlayerHud: SKShapeNode {
    let headNode: SKSpriteNode
    let healthNode: HealthInfoNode
    let powerUpsNode: PowerUpsInfoNode
    let livesNode = SKLabelNode()
    let scoreTitleNode = SKLabelNode()
    let scoreValueNode = SKLabelNode()
    
    // MARK: - Initialization
    
    init(size: CGSize, forPlayer player: PlayerIndex) {
        let imageName = player == .Player1 ? "Player 1 Head.png" : "Player 2 Head.png"
        let headTexture = SKTexture(imageNamed: imageName)
        self.headNode = SKSpriteNode(texture: headTexture, color: SKColor.purpleColor(), size: headTexture.size())
        self.healthNode = HealthInfoNode(size: CGSize(width: 205, height: 110))
        self.powerUpsNode = PowerUpsInfoNode(size: CGSize(width: 205, height: 80))

        super.init()
        
        self.path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)
        
        let x = size.width / 2
        
        self.headNode.position = CGPoint(x: 80, y: size.height - 45)
        self.addChild(headNode)
        
        self.healthNode.position = CGPoint(x: 10, y: 190)
        addChild(self.healthNode)
        
        self.powerUpsNode.position = CGPoint(x: 10, y: 115)
        addChild(self.powerUpsNode)

        self.livesNode.text = "Lives: 0"
        self.livesNode.fontName = "TamilSangamMN"
        self.livesNode.fontSize = 35
        self.livesNode.position = CGPoint(x: 140, y: size.height - 55)
        addChild(self.livesNode)
        
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
//        self.lineWidth = 4
//        self.strokeColor = SKColor.redColor()
//        self.fillColor = SKColor.blueColor()
        self.blendMode = .Add
        
        self.zPosition = 15
    }

    required init?(coder aDecoder: NSCoder) {
        let headTexture = SKTexture(imageNamed: "Player 1 Head.png")
        self.headNode = SKSpriteNode(texture: headTexture, color: SKColor.purpleColor(), size: headTexture.size())
        self.healthNode = HealthInfoNode(size: CGSize(width: 150, height: 100))
        self.powerUpsNode = PowerUpsInfoNode(size: CGSize(width: 205, height: 110))
        
        super.init(coder: aDecoder)
    }

    // MARK: - Public
    
    func updateLives(lives: Int) {
        self.livesNode.text = String(format: "x\(lives + 1)")
    }
    
    func updateHealth(health: Int) {
        self.healthNode.updateHealth(health)
    }
    
    func updatePower(power: PowerType, setActive isActive: Bool) {
        self.powerUpsNode.updatePower(power, setActive: isActive)
    }    
}
