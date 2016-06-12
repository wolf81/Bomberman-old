//
//  GameViewController.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 22/04/16.
//
//

// MARK: - tvOS -

import SpriteKit
import GameController

#if os(tvOS)
    
import UIKit

class GameViewController: GCEventViewController {
    private var sceneController: SceneController!
    private var gameView: GameView!
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    private func commonInit() {
        self.sceneController = SceneController(gameViewController: self)
    }

    // MARK: - View lifecycle 
    
    override func loadView() {
        gameView = GameView()
        self.view = gameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameView.showsDrawCount = true
        self.gameView.showsFPS = true
        self.gameView.showsNodeCount = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let scene = LoadingScene(size: self.gameView.bounds.size, loadingSceneDelegate: self.sceneController)
        self.gameView.presentScene(scene)
    }
    
    // MARK: - Public
    
    func presentScene(scene: SKScene, withTransition transition: SKTransition) {
        self.gameView.presentScene(scene, transition: transition)
    }
    
    // MARK: - GameController suppport
    
    func configureController(controller: GCController, forPlayer player: GCControllerPlayerIndex) {
        controller.playerIndex = player
                
        controller.controllerPausedHandler = { [unowned self] _ in
            print("pause / resume game")
            
            if let scene = self.gameView.scene {
                scene.paused = !scene.paused
            }
        }
        
        let playerIndex: PlayerIndex = player == .Index1 ? .Player1 : .Player2
        
        if let profile = controller.microGamepad {
            profile.allowsRotation = true
            profile.reportsAbsoluteDpadValues = true
            profile.buttonX.pressedChangedHandler = { _, value, pressed in
                if pressed {
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex, action: PlayerAction.Action)
                }
            }

            profile.buttonX.pressedChangedHandler = { _, value, pressed in
                if pressed {
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex, action: PlayerAction.Action)
                }
            }

            profile.dpad.valueChangedHandler = { _, xValue, yValue in
                let centerOffset: Float = 0.25
                
                if fabs(xValue) < centerOffset && fabs(yValue) < centerOffset {
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex,
                                                                   action: PlayerAction.None)
                } else if fabs(xValue) > fabs(yValue) {
                    let action: PlayerAction = xValue > 0 ? PlayerAction.Right : PlayerAction.Left
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex,
                                                                   action: action)
                } else {
                    let action: PlayerAction = yValue > 0 ? PlayerAction.Up : PlayerAction.Down
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex,
                                                                   action: action)
                }
            }
        } else if let profile = controller.gamepad {
            profile.dpad.valueChangedHandler = { _, xValue, yValue in
                let centerOffset: Float = 0.10
                
                if fabs(xValue) < centerOffset && fabs(yValue) < centerOffset {
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex,
                                                                   action: PlayerAction.None)
                } else if fabs(xValue) > fabs(yValue) {
                    let action: PlayerAction = xValue > 0 ? PlayerAction.Right : PlayerAction.Left
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex,
                                                                   action: action)
                } else {
                    let action: PlayerAction = yValue > 0 ? PlayerAction.Up : PlayerAction.Down
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex,
                                                                   action: action)
                }
            }
            
            profile.buttonA.pressedChangedHandler = { _, value, pressed in
                if pressed {
                    Game.sharedInstance.handlePlayerDidStartAction(playerIndex, action: PlayerAction.Action)
                }
            }
        }
    }
}

#else

// MARK: - OS X -
    
import Cocoa

class GameViewController: NSViewController {
    private var sceneController: SceneController!
    private var gameView: GameView!
    
    // MARK: - Initialization
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }

    private func commonInit() {
        self.sceneController = SceneController(gameViewController: self)
    }

    // MARK: - View lifecycle
    
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
        
        let scene = LoadingScene(size: self.gameView.bounds.size, loadingSceneDelegate: self.sceneController)
        self.gameView.presentScene(scene)
    }

    // MARK: - Public
    
    func presentScene(scene: SKScene, withTransition transition: SKTransition) {
        self.gameView.presentScene(scene, transition: transition)
    }
    
    // MARK: - GameController suppport
    
    func configureController(controller: GCController, forPlayer player: GCControllerPlayerIndex) {
        controller.playerIndex = player
        
        controller.controllerPausedHandler = { [unowned self] _ in
            print("pause / resume game")
            
            if let scene = self.gameView.scene {
                scene.paused = !scene.paused
            }
        }
        
        if self.gameView.scene != nil {
            if let dpad = controller.gamepad?.dpad {
                dpad.valueChangedHandler = { _, xValue, yValue in
                    let centerOffset: Float = 0.10
                    
                    if fabs(xValue) < centerOffset && fabs(yValue) < centerOffset {
                        Game.sharedInstance.handlePlayerDidStartAction(PlayerIndex.Player1,
                                                                       action: PlayerAction.None)
                    } else if fabs(xValue) > fabs(yValue) {
                        let action: PlayerAction = xValue > 0 ? PlayerAction.Right : PlayerAction.Left
                        Game.sharedInstance.handlePlayerDidStartAction(PlayerIndex.Player1,
                                                                       action: action)
                    } else {
                        let action: PlayerAction = yValue > 0 ? PlayerAction.Up : PlayerAction.Down
                        Game.sharedInstance.handlePlayerDidStartAction(PlayerIndex.Player1,
                                                                       action: action)
                    }
                }
            }
            
            if let buttonA = controller.gamepad?.buttonA {
                buttonA.pressedChangedHandler = { _, value, pressed in
                    if pressed {
                        Game.sharedInstance.handlePlayerDidStartAction(PlayerIndex.Player1, action: PlayerAction.Action)
                    }
                }
            }
        }
    }
}

#endif