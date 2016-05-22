//
//  GameScene.swift
//  Bomberman-OSX
//
//  Created by Wolfgang Schreurs on 22/04/16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

import SpriteKit

@objc protocol GameSceneDelegate: SKSceneDelegate {
    func gameSceneDidMoveToView(scene: GameScene, view: SKView)
    
    func gameScenePlayerDidStartAction(scene: GameScene, player: PlayerIndex, action: PlayerAction)
    func gameScenePlayerDidStopAction(scene: GameScene, player: PlayerIndex, action: PlayerAction)
    
    func gameSceneDidFinishLevel(scene: GameScene, level: Level)
}

class GameScene: SKScene {
    private(set) var level: Level?
    
    private let rootNode: GameSceneNode
    
    var world: SKSpriteNode {
        return self.rootNode.world
    }
    
    init(level: Level, gameSceneDelegate: GameSceneDelegate?) {
        // TODO: Consider not instantiating with level, but with sizes for panel and world and the 
        //  theme. Scene might not be recreated for every level?
        self.rootNode = GameSceneNode(withLevel: level)
        
        super.init(size: self.rootNode.frame.size)
        
        self.addChild(self.rootNode)

        self.level = level
        self.gameSceneDelegate = gameSceneDelegate
        self.physicsWorld.gravity = CGVector()
        
        self.scaleMode = .AspectFit
    }
    
    func updateTimeRemaining(timeRemaining: NSTimeInterval) {
        self.rootNode.updateTimeRemaining(timeRemaining)
    }
    
    func updatePlayer(playerIndex: PlayerIndex, setLives lives: Int) {
        self.rootNode.updatePlayer(playerIndex, setLives: lives)
    }
    
    func updatePlayer(playerIndex: PlayerIndex, setHealth health: Int) {
        self.rootNode.updatePlayer(playerIndex, setHealth: health)
    }
    
    func levelFinished(level: Level) {
        if let delegate = self.gameSceneDelegate {
            delegate.gameSceneDidFinishLevel(self, level: level);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    // Work around to set the subclass delegate.
    var gameSceneDelegate: GameSceneDelegate? {
        get { return self.delegate as? GameSceneDelegate }
        set { self.delegate = newValue }
    }
    
    override func didMoveToView(view: SKView) {
        if let delegate = self.gameSceneDelegate {
            delegate.gameSceneDidMoveToView(self, view: view)
        }        
    }
    
    #if os(tvOS)
    
    // handle user interaction
    
    #else

    override func keyDown(theEvent: NSEvent) {
        if let delegate = self.gameSceneDelegate {
            let playerAction = playerActionForKeyCode(theEvent.keyCode)

            if let player = playerAction.player {
                if let action = playerAction.action {
                    delegate.gameScenePlayerDidStartAction(self, player: player, action: action)
                }
            }
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        if let delegate = self.gameSceneDelegate {
            let playerAction = playerActionForKeyCode(theEvent.keyCode)
            
            if let player = playerAction.player {
                if let action = playerAction.action {
                    if action != .DropBomb {
                        delegate.gameScenePlayerDidStopAction(self, player: player, action: action)
                    }
                }
            }
        }
    }
    
    #endif

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        Game.sharedInstance.update(currentTime)
    }
    
    private func playerActionForKeyCode(keyCode: UInt16) -> (player: PlayerIndex?, action: PlayerAction?) {
        var player: PlayerIndex? = nil
        var action: PlayerAction?
        
        if [123, 124, 125, 126, 49].contains(keyCode) {
            switch keyCode {
            case 123: action = PlayerAction.MoveLeft
            case 124: action = PlayerAction.MoveRight
            case 125: action = PlayerAction.MoveDown
            case 126: action = PlayerAction.MoveUp
            case 49: action = PlayerAction.DropBomb
            default: break
            }
            
            player = PlayerIndex.Player1
        } else if [0, 1, 2, 13].contains(keyCode) {
            switch keyCode {
            case 0: action = PlayerAction.MoveLeft
            case 1: action = PlayerAction.MoveDown
            case 2: action = PlayerAction.MoveRight
            case 13: action = PlayerAction.MoveUp
            default: break
            }
            
            player = PlayerIndex.Player2
        }

        return (player: player, action: action)
    }
}
