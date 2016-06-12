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
}

class GameScene: BaseScene {
    private(set) var level: Level?
    
    private let rootNode: GameSceneNode
    
    var world: SKSpriteNode {
        return self.rootNode.world
    }
    
    // Work around to set the subclass delegate.
    var gameSceneDelegate: GameSceneDelegate? {
        get { return self.delegate as? GameSceneDelegate }
        set { self.delegate = newValue }
    }

    // MARK: - Initialization
    
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

    required init?(coder aDecoder: NSCoder) {
        // TODO: Make proper implementation.
        return nil
    }
    
    // MARK: - Public

    func updateTimeRemaining(timeRemaining: NSTimeInterval) {
        self.rootNode.updateTimeRemaining(timeRemaining)
    }
    
    func updateHudForPlayer(player: Player) {
        self.rootNode.updateHudForPlayer(player)
    }
    
    func levelFinished(level: Level) {
        if let delegate = self.gameSceneDelegate {
            delegate.gameSceneDidFinishLevel(self, level: level);
        }
    }
    
    override func didMoveToView(view: SKView) {
        if let delegate = self.gameSceneDelegate {
            delegate.gameSceneDidMoveToView(self, view: view)
        }        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        Game.sharedInstance.update(currentTime)
    }
    
    override func handleUpPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .Up)
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: .Down)
    }
    
    override func handlePausePress(forPlayer: PlayerIndex) {
        self.paused = !self.paused
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
