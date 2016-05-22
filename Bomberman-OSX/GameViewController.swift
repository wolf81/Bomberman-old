//
//  GameViewController.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 22/04/16.
//
//

#if os(tvOS)

import SpriteKit
import GameController

class GameViewController: GCEventViewController {
    private(set) var gameView: GameView!
    
    override func loadView() {
        gameView = GameView()
        self.view = gameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameView.presentScene(Game.sharedInstance.gameScene)
    }
}

#else

import SpriteKit
import Cocoa

class GameViewController: NSViewController, LoadingSceneDelegate, GameSceneDelegate {
    private var gameView: GameView!
    
    override func loadView() {
        gameView = GameView()
        self.view = gameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Load assets (if applicable).
        // 2. Show menuScene after succesful asset loading (not in debug mode).        
        // 3. When user selects 'New Game' transition to gameScene.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let scene = LoadingScene(size: self.gameView.bounds.size, loadingSceneDelegate: self)
        self.gameView.presentScene(scene)
    }
    
    func loadingSceneDidFinishLoading() {
        if let level = Game.sharedInstance.loadLevel(0) {
            let gameScene = GameScene(level: level, gameSceneDelegate: self)
            Game.sharedInstance.configureScene(gameScene)
            
            self.gameView.presentScene(gameScene)
        }
    }
    
    func loadingSceneDidMoveToView(scene: LoadingScene, view: SKView) {
        do {
            try scene.updateAssetsIfNeeded()
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func gameSceneDidMoveToView(scene: GameScene, view: SKView) {
        Game.sharedInstance.configureLevel()
    }
    
    func gameSceneDidFinishLevel(scene: GameScene, level: Level) {
        print("level finished")
        
        if let level = Game.sharedInstance.loadLevel(0) {
            let gameScene = GameScene(level: level, gameSceneDelegate: self)
            Game.sharedInstance.configureScene(gameScene)
            
            self.gameView.presentScene(gameScene)
        }
    }
    
    func gameScenePlayerDidStopAction(scene: GameScene, player: PlayerIndex, action: PlayerAction) {
        Game.sharedInstance.handlePlayerDidStopAction(scene, player: player, action: action)
    }
    
    func gameScenePlayerDidStartAction(scene: GameScene, player: PlayerIndex, action: PlayerAction) {
        Game.sharedInstance.handlePlayerDidStartAction(scene, player: player, action: action)
    }
}

#endif

