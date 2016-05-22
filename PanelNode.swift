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
        let yMargin: CGFloat = 100
        let infoNodeSize = CGSizeMake(size.width, (size.height - (yMargin * 2)) / 2 - 100)
        self.p1_infoNode = PlayerInfoNode(size: infoNodeSize, text: "Player 1")
        self.p2_infoNode = PlayerInfoNode(size: infoNodeSize, text: "Player 2")
        
        super.init(texture: nil, color: SKColor.blackColor(), size: size)
        
        addChild(self.timeNode)
        self.timeNode.fontName = "TamilSangamMN-Bold"
        self.timeNode.fontSize = 40
        self.timeNode.position = CGPoint(x: size.width / 2, y: size.height / 2 - timeNode.frame.height / 2)
        
        addChild(self.p1_infoNode)
        self.p1_infoNode.position = CGPoint(x: 0, y: size.height - infoNodeSize.height - yMargin)
        
        addChild(self.p2_infoNode)
        self.p2_infoNode.position = CGPoint(x: 0, y: yMargin)
        
        self.anchorPoint = CGPointZero
        self.position = CGPointZero
        self.blendMode = .Replace
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
}