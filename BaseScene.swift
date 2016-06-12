//
//  BaseScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 12/06/16.
//
//

import SpriteKit

class BaseScene: SKScene {
    
    func handlePausePress(forPlayer: PlayerIndex) {
    
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

    #if os(tvOS)
    
    // handle user interaction
    
    #else
    
    override func keyDown(theEvent: NSEvent) {
        if let playerAction = playerActionForKeyCode(theEvent.keyCode) {
            switch playerAction.action {
            case .DropBomb: handleActionPress(forPlayer: playerAction.player)
            case .MoveLeft: handleLeftPress(forPlayer: playerAction.player)
            case .MoveRight: handleRightPress(forPlayer: playerAction.player)
            case .MoveUp: handleUpPress(forPlayer: playerAction.player)
            case .MoveDown: handleDownPress(forPlayer: playerAction.player)
            default: break
            }
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        if let playerAction = playerActionForKeyCode(theEvent.keyCode) {
            switch playerAction.action {
            case .DropBomb: handleActionRelease(forPlayer: playerAction.player)
            case .MoveLeft: handleLeftRelease(forPlayer: playerAction.player)
            case .MoveRight: handleRightRelease(forPlayer: playerAction.player)
            case .MoveUp: handleUpRelease(forPlayer: playerAction.player)
            case .MoveDown: handleDownRelease(forPlayer: playerAction.player)
            default: break
            }
        }
    }
    
    #endif
    
    // MARK: - Private
    
    private func playerActionForKeyCode(keyCode: UInt16) -> (player: PlayerIndex, action: PlayerAction)? {
        var result: (PlayerIndex, PlayerAction)?
        
        if keyCode == 53 {
            result = (PlayerIndex.Player1, PlayerAction.Pause)
        } else if [123, 124, 125, 126, 49].contains(keyCode) {
            switch keyCode {
            case 123: result = (.Player1, .MoveLeft)
            case 124: result = (.Player1, .MoveRight)
            case 125: result = (.Player1, .MoveDown)
            case 126: result = (.Player1, .MoveUp)
            case 49: result = (.Player1, .DropBomb)
            default: break
            }
        } else if [0, 1, 2, 13, 53].contains(keyCode) {
            switch keyCode {
            case 0: result = (.Player2, .MoveLeft)
            case 1: result = (.Player2, .MoveDown)
            case 2: result = (.Player2, .MoveRight)
            case 13: result = (.Player2, .MoveUp)
            default: break
            }
        }
        
        return result
    }
}