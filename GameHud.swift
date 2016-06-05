//
//  PanelNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/05/16.
//
//

import SpriteKit

class GameHud: SKSpriteNode {

    let timeNode = SKLabelNode(text: "00:00")
    
    let p1Hud: PlayerHud
    let p2Hud: PlayerHud
    
    init(size: CGSize) {
        let infoNodeSize = CGSize(width: 225, height: 380)
        self.p1Hud = PlayerHud(size: infoNodeSize, forPlayer: .Player1)
        self.p2Hud = PlayerHud(size: infoNodeSize, forPlayer: .Player2)
        
        let texture = SKTexture(imageNamed: "Panel.png")
        super.init(texture: texture, color: SKColor.blackColor(), size: size)
        
        self.timeNode.zPosition = 10
        addChild(self.timeNode)
        self.timeNode.fontName = "TamilSangamMN-Bold"
        self.timeNode.fontSize = 40
        self.timeNode.position = CGPoint(x: size.width / 2, y: size.height / 2 - timeNode.frame.height / 2)
        
        addChild(self.p1Hud)
        self.p1Hud.position = CGPoint(x: 55, y: 590)
        
        addChild(self.p2Hud)
        self.p2Hud.position = CGPoint(x: 55, y: 115)
        
        self.anchorPoint = CGPointZero
        self.position = CGPointZero
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func updateTimeRemaining(timeRemaining: NSTimeInterval) {
        let minutes = String(format: "%02d", Int(timeRemaining / 60))
        let seconds = String(format: "%02d", Int(timeRemaining % 60))
        self.timeNode.text = "\(minutes):\(seconds)"
    }
    
    func updateForPlayer(player: Player) {
        let playerInfoNode = player.index == .Player1 ? self.p1Hud : self.p2Hud
        playerInfoNode.updateLives(player.lives)
        playerInfoNode.updateHealth(player.health)
        
        let explosionPowerActive = player.explosionPowerLimit.currentCount > 0
        playerInfoNode.updatePower(PowerType.ExplosionSize, setActive: explosionPowerActive)
        
        let bombPowerActive = player.bombPowerLimit.currentCount > 0
        playerInfoNode.updatePower(PowerType.BombAdd, setActive: bombPowerActive)
        
        let triggerPowerActive = player.bombTriggerPowerLimit.currentCount > 0
        playerInfoNode.updatePower(PowerType.BombSpeed, setActive: triggerPowerActive)
        
        let shieldPowerActive = player.shieldPowerLimit.currentCount > 0
        playerInfoNode.updatePower(PowerType.Shield, setActive: shieldPowerActive)
        
        let speedPowerActive = player.speedPowerLimit.currentCount > 0
        playerInfoNode.updatePower(PowerType.MoveSpeed, setActive: speedPowerActive)
    }
}