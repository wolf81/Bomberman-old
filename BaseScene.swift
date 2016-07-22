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
    
    override func keyDown(theEvent: NSEvent) {
        if let playerAction = playerActionForKeyCode(theEvent.keyCode) {
            switch playerAction.action {
            case .Action: handleActionPress(forPlayer: playerAction.player)
            case .Left: handleLeftPress(forPlayer: playerAction.player)
            case .Right: handleRightPress(forPlayer: playerAction.player)
            case .Up: handleUpPress(forPlayer: playerAction.player)
            case .Down: handleDownPress(forPlayer: playerAction.player)
            case .Pause: handlePausePress(forPlayer: playerAction.player)
            default: break
            }
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        if let playerAction = playerActionForKeyCode(theEvent.keyCode) {
            switch playerAction.action {
            case .Action: handleActionRelease(forPlayer: playerAction.player)
            case .Left: handleLeftRelease(forPlayer: playerAction.player)
            case .Right: handleRightRelease(forPlayer: playerAction.player)
            case .Up: handleUpRelease(forPlayer: playerAction.player)
            case .Down: handleDownRelease(forPlayer: playerAction.player)
            case .Pause: handlePausePress(forPlayer: playerAction.player)
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
    
    private func playerActionForKeyCode(keyCode: UInt16) -> (player: PlayerIndex, action: PlayerAction)? {
        var result: (PlayerIndex, PlayerAction)?
        
        switch keyCode {
        // Player 1
        case 53: result = (.Player1, .Pause)
        case 123: result = (.Player1, .Left)
        case 124: result = (.Player1, .Right)
        case 125: result = (.Player1, .Down)
        case 126: result = (.Player1, .Up)
        case 49: result = (.Player1, .Action)

        // Player 2
        case 0: result = (.Player2, .Left)
        case 1: result = (.Player2, .Down)
        case 2: result = (.Player2, .Right)
        case 13: result = (.Player2, .Up)            
        default: break
        }
        
        return result
    }
}