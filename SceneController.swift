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

class SceneController: NSObject, GameSceneDelegate, LoadingSceneDelegate {
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
        
        let menuScene = MenuScene(size: self.defaultSize, options: mainMenuOptions())
        transitionToScene(menuScene, animation: .Fade)
    }
    
    // MARK: - LoadingSceneDelegate
    
    func loadingSceneDidFinishLoading(scene: LoadingScene) {
        let menuScene = MenuScene(size: self.defaultSize, options: mainMenuOptions())
        transitionToScene(menuScene, animation: .Fade)
    }
    
    func loadingSceneDidMoveToView(scene: LoadingScene, view: SKView) {
        do {
            try scene.updateAssetsIfNeeded()
        } catch let error {
            print("error: \(error)")
        }
    }
    
    // MARK: - Private
    
    private func showSubMenuWithOptions(options: [MenuOption]) {
        let scene = MenuScene(size: self.defaultSize, options: options, alignWithLastItem: true)
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
}

// MARK: - Menu options for main menu and sub menus

extension SceneController {
    private func settingsOptions() -> [MenuOption] {
        let backItem = MenuOption(title: "BACK") {
            let options = self.mainMenuOptions()
            let menuScene = MenuScene(size: self.defaultSize, options: options)
            self.transitionToScene(menuScene, animation: .Pop)
        }
        
        let enabled = Settings.musicEnabled()
        let playMusicItem = MenuOption(title: "PLAY MUSIC", type: .Checkbox, value: enabled) { newValue in
            if let enabled = newValue as? Bool {
                Settings.setMusicEnabled(enabled)
            }
        }
        
        return [playMusicItem, backItem]
    }
    
    private func developerOptions() -> [MenuOption] {
        let backItem = MenuOption(title: "BACK") {
            let options = self.mainMenuOptions()
            let menuScene = MenuScene(size: self.defaultSize, options: options)
            self.transitionToScene(menuScene, animation: .Pop)
        }
        
        let levelIdx = Settings.initialLevel()
        let initialLevelItem = MenuOption(title: "INITIAL LEVEL", type: .NumberChooser, value: levelIdx) { newValue in
            if let index = newValue as? Int {
                Settings.setInitialLevel(index)
            }
        }
        
        initialLevelItem.onValidate = { newValue in
            var isValid = false
            
            if let index = newValue as? Int {
                let maxIndex = max(LevelLoader.levelCount - 1, 0)
                isValid = (0 ... maxIndex).contains(index)
            }
            
            return isValid
        }
        
        let enabled = Settings.assetsCheckEnabled()
        let checkAssetsItem = MenuOption(title: "CHECK ASSETS ON START-UP", type: .Checkbox, value: enabled) { newValue in
            if let enabled = newValue as? Bool {
                Settings.setAssetsCheckEnabled(enabled)
            }
        }
        
        return [initialLevelItem, checkAssetsItem, backItem]
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
            let options = self.settingsOptions()
            self.showSubMenuWithOptions(options)
        }
        
        let developerItem = MenuOption(title: "DEVELOPER") {
            let options = self.developerOptions()
            self.showSubMenuWithOptions(options)
        }
        
        return [newGameItem, continueItem, settingsItem, developerItem]
    }
}