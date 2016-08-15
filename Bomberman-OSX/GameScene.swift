//
//  GameScene.swift
//  Bomberman-OSX
//
//  Created by Wolfgang Schreurs on 22/04/16.
//

import SpriteKit

protocol GameSceneDelegate: SKSceneDelegate {
    func gameSceneDidMoveToView(scene: GameScene, view: SKView)
    func gameSceneDidFinishLevel(scene: GameScene, level: Level)
    func gameSceneDidPause(scene: GameScene)
}

class GameScene: BaseScene {
    private(set) var level: Level?
    
    // The previous update time is used to calculate the delta time. Entities, components, etc...
    //  are updated using the delta time (time difference since last update).
    private var previousUpdateTime: NSTimeInterval = -1

    private let rootNode: GameSceneNode
    
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
        
        scaleMode = .AspectFit
        physicsWorld.gravity = CGVector()
    }

    required init?(coder aDecoder: NSCoder) {
        // TODO: Make proper implementation.
        return nil
    }
    
    // MARK: - Public
    
    func updateTimeRemaining(timeRemaining: NSTimeInterval) {
        rootNode.updateTimeRemaining(timeRemaining)
    }
    
    func updateHudForPlayer(player: Player) {
        rootNode.updateHudForPlayer(player)
    }
    
    func levelFinished(level: Level) {
        if let delegate = gameSceneDelegate {
            delegate.gameSceneDidFinishLevel(self, level: level);
        }
    }
    
    override func didMoveToView(view: SKView) {
        if let delegate = gameSceneDelegate {
            delegate.gameSceneDidMoveToView(self, view: view)
        }        
    }
    
    override func update(currentTime: CFTimeInterval) {
        // Make sure the previous update time is never negative (e.g.: due to overflow of time
        //  interval)
        if previousUpdateTime < 0 {
            previousUpdateTime = currentTime
        }        
        
        let deltaTime = currentTime - previousUpdateTime;
        previousUpdateTime = currentTime;

        Game.sharedInstance.update(deltaTime)
    }
    
    override func handleUpPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .Up)
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .Down)
    }
    
    override func handlePausePress(forPlayer player: PlayerIndex) {
        paused = true
                
        if let delegate = gameSceneDelegate {
            delegate.gameSceneDidPause(self)
        }
    }
    
    override func handleLeftPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .Left)
    }
    
    override func handleRightPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .Right)
    }
    
    override func handleActionPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .Action)
    }

    override func handleUpRelease(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: .Up)
    }
    
    override func handleDownRelease(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: .Down)
    }
    
    override func handleLeftRelease(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: .Left)
    }
    
    override func handleRightRelease(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: .Right)
    }
    
    override func handleActionRelease(forPlayer player: PlayerIndex) {
        //
    }
}
