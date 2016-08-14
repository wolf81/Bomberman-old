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
        p1Hud = PlayerHud(size: infoNodeSize, forPlayer: .Player1)
        p2Hud = PlayerHud(size: infoNodeSize, forPlayer: .Player2)
        
        let texture = SKTexture(imageNamed: "Panel.png")
        super.init(texture: texture, color: SKColor.blackColor(), size: size)
        
        timeNode.zPosition = 10
        timeNode.fontName = "TamilSangamMN-Bold"
        timeNode.fontSize = 40
        timeNode.position = CGPoint(x: size.width / 2, y: size.height / 2 - timeNode.frame.height / 2)
        addChild(timeNode)
        
        addChild(p1Hud)
        p1Hud.position = CGPoint(x: 55, y: 590)
        
        addChild(p2Hud)
        p2Hud.position = CGPoint(x: 55, y: 115)
        
        anchorPoint = CGPointZero
        position = CGPointZero
        blendMode = .Replace
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func updateTimeRemaining(timeRemaining: NSTimeInterval) {
        let minutes = String(format: "%02d", Int(timeRemaining / 60))
        let seconds = String(format: "%02d", Int(timeRemaining % 60))
        timeNode.text = "\(minutes):\(seconds)"
    }
    
    func updateForPlayer(player: Player) {
        let playerInfoNode = player.index == .Player1 ? p1Hud : p2Hud
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

        let movePowerActive = player.moveSpeedPowerLimit.currentCount > 0
        playerInfoNode.updatePower(PowerType.MoveSpeed, setActive: movePowerActive)
    }
}