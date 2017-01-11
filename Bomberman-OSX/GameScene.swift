//
//  GameScene.swift
//  Bomberman-OSX
//
//  Created by Wolfgang Schreurs on 22/04/16.
//

import SpriteKit

protocol GameSceneDelegate: SKSceneDelegate {
    func gameSceneDidMoveToView(_ scene: GameScene, view: SKView)
    func gameSceneDidFinishLevel(_ scene: GameScene, level: Level)
    func gameSceneDidPause(_ scene: GameScene)
}

class GameScene : BaseScene {
    fileprivate(set) var level: Level?
    
    // The previous update time is used to calculate the delta time. The delta time is used to 
    //  update the Game state.
    fileprivate var lastUpdateTime: TimeInterval = 0

    fileprivate let rootNode: GameSceneNode
    
    var world: SKSpriteNode {
        return rootNode.world
    }
    
    // Work around to set the subclass delegate.
    var gameSceneDelegate: GameSceneDelegate? {
        get { return delegate as? GameSceneDelegate }
        set { delegate = newValue }
    }

    // MARK: - Initialization
    
    init(level: Level, gameSceneDelegate: GameSceneDelegate?) {
        // TODO: Consider not instantiating with level, but with sizes for panel and world and the 
        //  theme. Scene might not be recreated for every level?
        rootNode = GameSceneNode(withLevel: level)
        
        super.init(size: rootNode.frame.size)
        
        addChild(rootNode)

        self.level = level
        self.gameSceneDelegate = gameSceneDelegate
        
        scaleMode = .aspectFit
        physicsWorld.gravity = CGVector()
    }

    required init?(coder aDecoder: NSCoder) {
        // TODO: Make proper implementation.
        return nil
    }
    
    // MARK: - Public
    
    func updateTimeRemaining(_ timeRemaining: TimeInterval) {
        rootNode.updateTimeRemaining(timeRemaining)
    }
    
    func updateHudForPlayer(_ player: Player) {
        rootNode.updateHudForPlayer(player)
    }
    
    func levelFinished(_ level: Level) {
        if let delegate = gameSceneDelegate {
            delegate.gameSceneDidFinishLevel(self, level: level);
        }
    }
    
    override func didMove(to view: SKView) {
        if let delegate = gameSceneDelegate {
            delegate.gameSceneDidMoveToView(self, view: view)
        }        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // NOTE: After pausing the game, the last update time is reset to the current time. The 
        //  next time the update loop is entered, a correct delta time can then be calculated using
        //  the current time and the last update time.
        if lastUpdateTime <= 0 {
            lastUpdateTime = currentTime
        } else {
            let deltaTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            Game.sharedInstance.update(deltaTime)
        }
    }
    
    override func handleUpPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .up)
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .down)
    }
    
    override func handlePausePress(forPlayer player: PlayerIndex) {
        isPaused = true
        lastUpdateTime = 0
        
        if let delegate = gameSceneDelegate {
            delegate.gameSceneDidPause(self)
        }
    }
    
    override func handleLeftPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .left)
    }
    
    override func handleRightPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .right)
    }
    
    override func handleActionPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .action)
    }

    override func handleUpRelease(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: .up)
    }
    
    override func handleDownRelease(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: .down)
    }
    
    override func handleLeftRelease(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: .left)
    }
    
    override func handleRightRelease(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: .right)
    }
    
    override func handleActionRelease(forPlayer player: PlayerIndex) {
        //
    }
}
