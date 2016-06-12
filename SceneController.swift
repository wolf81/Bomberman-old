//
//  SceneController.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 01/06/16.
//
//

import SpriteKit

class SceneController: NSObject, GameSceneDelegate, LoadingSceneDelegate, MenuSceneDelegate {
    weak var gameViewController: GameViewController?
    
    init(gameViewController: GameViewController) {
        self.gameViewController = gameViewController        
    }
    
    // MARK: - GameSceneDelegate
    
    func gameSceneDidMoveToView(scene: GameScene, view: SKView) {
        Game.sharedInstance.configureLevel()
    }
    
    func gameSceneDidFinishLevel(scene: GameScene, level: Level) {
        transitionToLevel(level.index + 1)
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

    // MARK: - MenuSceneDelegate
    
    func menuScene(scene: MenuScene, optionSelected: MenuOption) {
        print("selected: \(optionSelected)")
        
        switch optionSelected {
        case .NewGame: transitionToLevel(0)
        default: break
        }
        
    }
    
    // MARK: - LoadingSceneDelegate
    
    func loadingSceneDidFinishLoading(scene: LoadingScene) {
        let menuScene = MenuScene(size: scene.size, delegate: self)
        transitionToScene(menuScene)
        
        return // -- DEBUG
        
//        transitionToLevel(0)        
    }
    
    func loadingSceneDidMoveToView(scene: LoadingScene, view: SKView) {
        do {
            try scene.updateAssetsIfNeeded()
        } catch let error {
            print("error: \(error)")
        }
    }
    
    // MARK: - Private
    
    private func transitionToScene(scene: BaseScene) {
        let transition = SKTransition.fadeWithDuration(0.5)
        self.gameViewController?.presentScene(scene, withTransition: transition)
    }
    
    private func transitionToLevel(levelIndex: Int) {
        print("transitioning to level: \(levelIndex)")
            
        do {
            let level = try loadLevel(levelIndex)
            let gameScene = GameScene(level: level, gameSceneDelegate: self)
            Game.sharedInstance.configureForGameScene(gameScene)
            transitionToScene(gameScene)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    private func loadLevel(levelIndex: Int) throws -> Level {
        print("loading level: \(levelIndex)")

        let levelParser = LevelLoader(forGame: Game.sharedInstance)
        let level = try levelParser.loadLevel(levelIndex)

        return level
    }
}