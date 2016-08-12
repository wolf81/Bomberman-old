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
}

#else

// MARK: - macOS -
    
import Cocoa

class GameViewController: NSViewController {
    private var sceneManager: SceneManager!
    private var gameView: GameView!
    private var infoOverlay: InfoOverlay?
    
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
        self.sceneManager = SceneManager(gameViewController: self)
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
        
        // TODO: Debug only.
        self.infoOverlay = InfoOverlay()
        self.gameView.addSubview(self.infoOverlay!)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let scene = LoadingScene(size: self.gameView.bounds.size, loadingSceneDelegate: self.sceneManager)
        self.gameView.presentScene(scene)
        
        let bounds = self.view.bounds
        let height: CGFloat = 50
        let frame = NSRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
        self.infoOverlay?.frame = frame
    }
    
    // MARK: - Public
    
    func presentScene(scene: SKScene, withTransition transition: SKTransition) {
        self.gameView.presentScene(scene, transition: transition)
    }
}

#endif