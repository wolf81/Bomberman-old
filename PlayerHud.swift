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
        headNode = SKSpriteNode(texture: headTexture, color: SKColor.purpleColor(), size: headTexture.size())
        healthNode = HealthInfoNode(size: CGSize(width: 205, height: 110))
        powerUpsNode = PowerUpsInfoNode(size: CGSize(width: 205, height: 80))

        super.init()
        
        path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)
        
        let x = size.width / 2
        
        headNode.position = CGPoint(x: 80, y: size.height - 45)
        addChild(headNode)
        
        healthNode.position = CGPoint(x: 10, y: 190)
        addChild(healthNode)
        
        powerUpsNode.position = CGPoint(x: 10, y: 115)
        addChild(powerUpsNode)

        livesNode.text = "Lives: 0"
        livesNode.fontName = "TamilSangamMN"
        livesNode.fontSize = 35
        livesNode.position = CGPoint(x: 140, y: size.height - 55)
        addChild(livesNode)
        
        scoreTitleNode.text = "SCORE"
        scoreTitleNode.position = CGPoint(x: x, y: 65)
        scoreTitleNode.fontName = "TamilSangamMN"
        scoreTitleNode.fontSize = 35
        addChild(scoreTitleNode)

        scoreValueNode.text = "000000"
        scoreValueNode.position = CGPoint(x: x, y: 25)
        scoreValueNode.fontName = "TamilSangamMN"
        scoreValueNode.fontSize = 35
        addChild(scoreValueNode)
        
        antialiased = false
//        self.lineWidth = 4
//        self.strokeColor = SKColor.redColor()
//        self.fillColor = SKColor.blueColor()
        blendMode = .Replace
        
        zPosition = 15
    }

    required init?(coder aDecoder: NSCoder) {
        let headTexture = SKTexture(imageNamed: "Player 1 Head.png")
        headNode = SKSpriteNode(texture: headTexture, color: SKColor.purpleColor(), size: headTexture.size())
        healthNode = HealthInfoNode(size: CGSize(width: 150, height: 100))
        powerUpsNode = PowerUpsInfoNode(size: CGSize(width: 205, height: 110))
        
        super.init(coder: aDecoder)
    }

    // MARK: - Public
    
    func updateLives(lives: Int) {
        livesNode.text = String(format: "x\(lives + 1)")
    }
    
    func updateHealth(health: Int) {
        healthNode.updateHealth(health)
    }
    
    func updatePower(power: PowerType, setActive isActive: Bool) {
        powerUpsNode.updatePower(power, setActive: isActive)
    }    
}
