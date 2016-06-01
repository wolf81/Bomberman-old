//
//  SceneController.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 01/06/16.
//
//

import SpriteKit

class SceneController: NSObject, GameSceneDelegate, LoadingSceneDelegate {    
    weak var gameViewController: GameViewController?
    
    init(gameViewController: GameViewController) {
        self.gameViewController = gameViewController        
    }
    
    // MARK: - GameSceneDelegate
    
    func gameSceneDidMoveToView(scene: GameScene, view: SKView) {
        Game.sharedInstance.configureLevel()
    }
    
    func gameSceneDidFinishLevel(scene: GameScene, level: Level) {
        print("level finished")
        
        if let level = Game.sharedInstance.loadLevel(0) {
            let gameScene = GameScene(level: level, gameSceneDelegate: self)
            Game.sharedInstance.configureScene(gameScene)
            
            let transition = SKTransition.fadeWithDuration(0.5)
            
            self.gameViewController?.presentScene(gameScene, withTransition: transition)
        }
    }
    
    func gameScenePlayerDidStopAction(scene: GameScene, player: PlayerIndex, action: PlayerAction) {
        Game.sharedInstance.handlePlayerDidStopAction(player, action: action)
    }
    
    func gameScenePlayerDidStartAction(scene: GameScene, player: PlayerIndex, action: PlayerAction) {
        Game.sharedInstance.handlePlayerDidStartAction(player, action: action)
    }
    
    func gameScenePlayerDidPause(scene: GameScene) {
        if let gameScene = Game.sharedInstance.gameScene {
            gameScene.paused = !gameScene.paused
        }
    }

    // MARK: - LoadingSceneDelegate
    
    func loadingSceneDidFinishLoading() {
        if let level = Game.sharedInstance.loadLevel(0) {
            let gameScene = GameScene(level: level, gameSceneDelegate: self)
            Game.sharedInstance.configureScene(gameScene)
            
            let transition = SKTransition.fadeWithDuration(0.5)
            
            self.gameViewController?.presentScene(gameScene, withTransition: transition)
        }
    }
    
    func loadingSceneDidMoveToView(scene: LoadingScene, view: SKView) {
        do {
            try scene.updateAssetsIfNeeded()
        } catch let error {
            print("error: \(error)")
        }
    }
}