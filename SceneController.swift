//
//  SceneController.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 01/06/16.
//
//

import SpriteKit

enum TransitionAnimation {
    case Fade
    case Push
    case Pop
}

class SceneController: NSObject, GameSceneDelegate, LoadingSceneDelegate, MenuSceneDelegate, SettingsSceneDelegate, DeveloperSceneDelegate {
    let defaultSize = CGSize(width: 1280, height: 720)
    
    weak var gameViewController: GameViewController?
    
    // Game scene for current game, if any. Used for pause / resume functionality. 
    var pausedGameScene: BaseScene?
        
    init(gameViewController: GameViewController) {
        self.gameViewController = gameViewController        
    }
    
    // MARK: - GameSceneDelegate
    
    func gameSceneDidMoveToView(scene: GameScene, view: SKView) {
        if scene != self.pausedGameScene {
            Game.sharedInstance.configureLevel()
        }
    }
    
    func gameSceneDidFinishLevel(scene: GameScene, level: Level) {
        showLevel(level.index + 1)
    }
        
    func gameSceneDidPause(scene: GameScene) {
        self.pausedGameScene = scene
        
        let menuScene = MenuScene(size: self.defaultSize, delegate: self, options: mainMenuOptions())
        transitionToScene(menuScene, animation: .Fade)
    }
    
    // MARK: - DeveloperSceneDelegate
    
    func developerScene(scene: DeveloperScene, optionSelected: DeveloperOption) {
        let menuScene = MenuScene(size: self.defaultSize, delegate: self, options: mainMenuOptions())
        transitionToScene(menuScene, animation: .Pop)
    }
    
    // MARK: - MenuSceneDelegate
    
    func menuScene(scene: MenuScene, optionSelected: MenuOption) {
        print("selected: \(optionSelected)")
        
        // TODO: Consider using a block in a constructor to handle selection actions.
        
        switch optionSelected.title {
        case "NEW GAME": let level = Settings.initialLevel(); showLevel(level)
        case "CONTINUE": continueLevel()
        case "SETTINGS": showSettings()
        case "DEVELOPER": showDeveloper()
        default: break
        }
    }
    
    // MARK: - LoadingSceneDelegate
    
    func loadingSceneDidFinishLoading(scene: LoadingScene) {
        let menuScene = MenuScene(size: self.defaultSize, delegate: self, options: mainMenuOptions())
        transitionToScene(menuScene, animation: .Fade)
    }
    
    func loadingSceneDidMoveToView(scene: LoadingScene, view: SKView) {
        do {
            try scene.updateAssetsIfNeeded()
        } catch let error {
            print("error: \(error)")
        }
    }
    
    // MARK: - SettingsSceneDelegate

    func settingsScene(scene: SettingsScene, optionSelected: SettingsOption) {
        let menuScene = MenuScene(size: self.defaultSize, delegate: self, options: mainMenuOptions())
        transitionToScene(menuScene, animation: .Pop)
    }
    
    // MARK: - Private

    private func showDeveloper() {
        let scene = DeveloperScene(size: self.defaultSize, delegate: self)
        transitionToScene(scene, animation: .Push)
    }
    
    private func showSettings() {
        let scene = SettingsScene(size: self.defaultSize, delegate: self)
        transitionToScene(scene, animation: .Push)
    }
    
    private func showLevel(levelIndex: Int) {
        do {
            let level = try loadLevel(levelIndex)
            let scene = GameScene(level: level, gameSceneDelegate: self)
            Game.sharedInstance.configureForGameScene(scene)
            transitionToScene(scene, animation: .Fade)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    private func continueLevel() {
        if let scene = self.pausedGameScene {
            transitionToScene(scene, animation: .Fade)
            
            Game.sharedInstance.resume()
        }
    }
    
    private func transitionToScene(scene: BaseScene, animation: TransitionAnimation) {
        var transition: SKTransition
        
        let duration = 0.5
        
        switch animation {
        case .Fade:
            transition = SKTransition.fadeWithDuration(duration)
        case .Push:
            transition = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: duration)
        case .Pop:
            transition = SKTransition.pushWithDirection(SKTransitionDirection.Right, duration: duration)
        }
        
        self.gameViewController?.presentScene(scene, withTransition: transition)
        
        InputProxy.sharedInstance.autoDirectionPressRelease = !(scene is GameScene)
        InputProxy.sharedInstance.scene = scene
    }

    private func loadLevel(levelIndex: Int) throws -> Level {
        let levelParser = LevelLoader(forGame: Game.sharedInstance)
        let level = try levelParser.loadLevel(levelIndex)
        return level
    }
    
    private func mainMenuOptions() -> [MenuOption] {
        let newGameItem = MenuOption(title: "NEW GAME") { 
            let level = Settings.initialLevel();
            self.showLevel(level)
        }
        
        let continueItem = MenuOption(title: "CONTINUE") {
            self.continueLevel()
        }
        
        let settingsItem = MenuOption(title: "SETTINGS") {
            self.showSettings()
        }
        
        let developerItem = MenuOption(title: "DEVELOPER") {
            self.showDeveloper()
        }
        
        let levelIdx = Settings.initialLevel()
        let testItem = MenuOption(title: "LEVEL", type: .NumberChooser, value: levelIdx)

        let enabled = Settings.musicEnabled()
        let backItem = MenuOption(title: "TEST", type: .Checkbox, value: enabled)

        let backItem2 = MenuOption(title: "BACK")

        return [newGameItem, continueItem, settingsItem, developerItem, testItem, backItem]
    }
}