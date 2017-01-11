//
//  BaseScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 12/06/16.
//
//

import SpriteKit

class BaseScene: SKScene {
    
    #if os(tvOS)
    
    // handle user interaction
    
    #else
    
    override func keyDown(with theEvent: NSEvent) {
        if let playerAction = playerActionForKeyCode(theEvent.keyCode) {
            switch playerAction.action {
            case .action: handleActionPress(forPlayer: playerAction.player)
            case .left: handleLeftPress(forPlayer: playerAction.player)
            case .right: handleRightPress(forPlayer: playerAction.player)
            case .up: handleUpPress(forPlayer: playerAction.player)
            case .down: handleDownPress(forPlayer: playerAction.player)
            case .pause: handlePausePress(forPlayer: playerAction.player)
            default: break
            }
        }
    }
    
    override func keyUp(with theEvent: NSEvent) {
        if let playerAction = playerActionForKeyCode(theEvent.keyCode) {
            switch playerAction.action {
            case .action: handleActionRelease(forPlayer: playerAction.player)
            case .left: handleLeftRelease(forPlayer: playerAction.player)
            case .right: handleRightRelease(forPlayer: playerAction.player)
            case .up: handleUpRelease(forPlayer: playerAction.player)
            case .down: handleDownRelease(forPlayer: playerAction.player)
            case .pause: handlePausePress(forPlayer: playerAction.player)
            default: break
            }
        }
    }
    
    #endif
    
    // MARK: - Public
    
    // Subclasses can override the following methods appropriate for the scene. E.g. in game can 
    //  move character up and down. In menu navigate through menu options.
    
    func handlePausePress(forPlayer player: PlayerIndex) {
    }
    
    func handleUpPress(forPlayer player: PlayerIndex) {
    }
    
    func handleUpRelease(forPlayer player: PlayerIndex) {
    }
    
    func handleDownPress(forPlayer player: PlayerIndex) {
    }
    
    func handleDownRelease(forPlayer player: PlayerIndex) {
    }
    
    func handleLeftPress(forPlayer player: PlayerIndex) {
    }
    
    func handleLeftRelease(forPlayer player: PlayerIndex) {
    }
    
    func handleRightPress(forPlayer player: PlayerIndex) {
    }
    
    func handleRightRelease(forPlayer player: PlayerIndex) {
    }
    
    func handleActionPress(forPlayer player: PlayerIndex) {
    }
    
    func handleActionRelease(forPlayer player: PlayerIndex) {
    }

    // MARK: - Private
    
    fileprivate func playerActionForKeyCode(_ keyCode: UInt16) -> (player: PlayerIndex, action: PlayerAction)? {
        var result: (PlayerIndex, PlayerAction)?
        
        switch keyCode {
        // Player 1
        case 53: result = (.player1, .pause)
        case 123: result = (.player1, .left)
        case 124: result = (.player1, .right)
        case 125: result = (.player1, .down)
        case 126: result = (.player1, .up)
        case 49: result = (.player1, .action)

        // Player 2
        case 0: result = (.player2, .left)
        case 1: result = (.player2, .down)
        case 2: result = (.player2, .right)
        case 13: result = (.player2, .up)            
        default: break
        }
        
        return result
    }
}
