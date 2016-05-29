//
//  GameViewController.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 22/04/16.
//
//

import SpriteKit
import GameController

#if os(tvOS)

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
        
        self.gameView.showsDrawCount = true
        self.gameView.showsFPS = true
        self.gameView.showsNodeCount = true
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

            let transition = SKTransition.fadeWithDuration(0.5)
            
            self.gameView.presentScene(gameScene, transition: transition)
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
            
            let transition = SKTransition.fadeWithDuration(0.5)

            self.gameView.presentScene(gameScene, transition: transition)
        }
    }
    
    func gameScenePlayerDidStopAction(scene: GameScene, player: PlayerIndex, action: PlayerAction) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: action)
    }
    
    func gameScenePlayerDidStartAction(scene: GameScene, player: PlayerIndex, action: PlayerAction) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: action)
    }
    
    func configureController(controller: GCController, forPlayer player: GCControllerPlayerIndex) {
        controller.playerIndex = player
        
        controller.controllerPausedHandler = { [unowned self] _ in
            print("pause / resume game")
            
            if let scene = self.gameView.scene {
                scene.paused = !scene.paused
            }
        }
        
        if let gameScene = self.gameView.scene {
            if let dpad = controller.gamepad?.dpad {
                dpad.valueChangedHandler = { _, xValue, yValue in
                    let centerOffset: Float = 0.10
                    
                    if fabs(xValue) < centerOffset && fabs(yValue) < centerOffset {
                        Game.sharedInstance.handlePlayerDidStartAction(PlayerIndex.Player1,
                                                                       action: PlayerAction.None)
                    } else if fabs(xValue) > fabs(yValue) {
                        let action: PlayerAction = xValue > 0 ? PlayerAction.MoveRight : PlayerAction.MoveLeft
                        Game.sharedInstance.handlePlayerDidStartAction(PlayerIndex.Player1,
                                                                       action: action)
                    } else {
                        let action: PlayerAction = yValue > 0 ? PlayerAction.MoveUp : PlayerAction.MoveDown
                        Game.sharedInstance.handlePlayerDidStartAction(PlayerIndex.Player1,
                                                                       action: action)
                    }
                }
            }
            
            if let buttonA = controller.gamepad?.buttonA {
                buttonA.pressedChangedHandler = { _, value, pressed in
                    if pressed {
                        Game.sharedInstance.handlePlayerDidStartAction(PlayerIndex.Player1, action: PlayerAction.DropBomb)
                    }
                }
            }
        }
    }
}

#endif