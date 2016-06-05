//
//  PanelNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/05/16.
//
//

import SpriteKit

class PanelNode: SKSpriteNode {

    let timeNode = SKLabelNode(text: "00:00")
    
    let p1_infoNode: PlayerInfoNode
    let p2_infoNode: PlayerInfoNode
    
    init(size: CGSize) {
        let infoNodeSize = CGSize(width: 225, height: 380)
        self.p1_infoNode = PlayerInfoNode(size: infoNodeSize, text: "Player 1")
        self.p2_infoNode = PlayerInfoNode(size: infoNodeSize, text: "Player 2")
        
        let texture = SKTexture(imageNamed: "Panel.png")
        super.init(texture: texture, color: SKColor.blackColor(), size: size)
        
        self.timeNode.zPosition = 10
        addChild(self.timeNode)
        self.timeNode.fontName = "TamilSangamMN-Bold"
        self.timeNode.fontSize = 40
        self.timeNode.position = CGPoint(x: size.width / 2, y: size.height / 2 - timeNode.frame.height / 2)
        
        addChild(self.p1_infoNode)
        self.p1_infoNode.position = CGPoint(x: 55, y: 115)
        
        addChild(self.p2_infoNode)
        self.p2_infoNode.position = CGPoint(x: 55, y: 590)
        
        self.anchorPoint = CGPointZero
        self.position = CGPointZero
//        self.blendMode = .Replace
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func updateTimeRemaining(timeRemaining: NSTimeInterval) {
        let minutes = String(format: "%02d", Int(timeRemaining / 60))
        let seconds = String(format: "%02d", Int(timeRemaining % 60))
        self.timeNode.text = "\(minutes):\(seconds)"
    }
    
    func updatePlayer(playerIndex: PlayerIndex, setLives lives: Int) {
        switch playerIndex {
        case .Player1: self.p1_infoNode.updateLives(lives)
        case .Player2: self.p2_infoNode.updateLives(lives)
        }
    }
    
    func updatePlayer(playerIndex: PlayerIndex, setHealth health: Int) {
        switch playerIndex {
        case .Player1: self.p1_infoNode.updateHealth(health)
        case .Player2: self.p2_infoNode.updateHealth(health)
        }
    }
    
    func updatePlayerPowers(forPlayer player: Player) {
        let explosionPowerActive = player.explosionPowerLimit.currentCount > 0
        let shieldPowerActive = player.shieldPowerLimit.currentCount > 0
        let speedPowerActive = player.speedPowerLimit.currentCount > 0
        let bombPowerActive = player.bombPowerLimit.currentCount > 0
        let triggerPowerActive = player.bombTriggerPowerLimit.currentCount > 0

        switch player.index {
        case .Player1:
            self.p1_infoNode.updatePower(PowerType.ExplosionSize, setActive: explosionPowerActive)
            self.p1_infoNode.updatePower(PowerType.BombAdd, setActive: bombPowerActive)
            self.p1_infoNode.updatePower(PowerType.BombSpeed, setActive: triggerPowerActive)
            self.p1_infoNode.updatePower(PowerType.Shield, setActive: shieldPowerActive)
            self.p1_infoNode.updatePower(PowerType.MoveSpeed, setActive: speedPowerActive)
        case .Player2:
            self.p2_infoNode.updatePower(PowerType.ExplosionSize, setActive: explosionPowerActive)
            self.p2_infoNode.updatePower(PowerType.BombAdd, setActive: bombPowerActive)
            self.p2_infoNode.updatePower(PowerType.BombSpeed, setActive: triggerPowerActive)
            self.p2_infoNode.updatePower(PowerType.Shield, setActive: shieldPowerActive)
            self.p2_infoNode.updatePower(PowerType.MoveSpeed, setActive: speedPowerActive)
        }
    }
}