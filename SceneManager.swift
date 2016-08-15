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

class SceneManager: NSObject {
    let defaultSize = CGSize(width: 1280, height: 720)
    
    weak var gameViewController: GameViewController?
    
    // Game scene for current game, if any. Used for pause / resume functionality. 
    var pausedGameScene: BaseScene?
        
    init(gameViewController: GameViewController) {
        self.gameViewController = gameViewController        
    }
    
    // MARK: - Private
    
    private func showMainMenu(withAnimation animation: TransitionAnimation) {
        let menuScene = MenuScene(size: self.defaultSize, options: mainMenuOptions())
        self.transitionToScene(menuScene, animation: animation)
    }
    
    private func showSubMenuWithOptions(options: [MenuOption]) {
        let scene = MenuScene(size: defaultSize, options: options, alignWithLastItem: true)
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
        if let scene = pausedGameScene {
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

// MARK: - Menu Options

extension SceneManager {
    private func settingsOptions() -> [MenuOption] {
        let backItem = MenuOption(title: "BACK") {
            self.showMainMenu(withAnimation: .Pop)
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
            self.showMainMenu(withAnimation: .Pop)
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
        
        let checkAssets = Settings.assetsCheckEnabled()
        let checkAssetsItem = MenuOption(title: "CHECK ASSETS ON START-UP", type: .Checkbox, value: checkAssets) { newValue in
            if let enabled = newValue as? Bool {
                Settings.setAssetsCheckEnabled(enabled)
            }
        }
        
        let showMenu = Settings.showMenuOnStartupEnabled()
        let showMenuOnStartUpItem = MenuOption(title: "SHOW MENU ON START-UP", type: .Checkbox, value: showMenu) { newValue in
            if let enabled = newValue as? Bool {
                Settings.setShowMenuOnStartupEnabled(enabled)
            }
        }
        
        return [initialLevelItem, checkAssetsItem, showMenuOnStartUpItem, backItem]
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
            self.showSubMenuWithOptions(self.settingsOptions())
        }
        
        let developerItem = MenuOption(title: "DEVELOPER") {
            self.showSubMenuWithOptions(self.developerOptions())
        }
        
        return [newGameItem, continueItem, settingsItem, developerItem]
    }
}

// MARK: - GameSceneDelegate

extension SceneManager: GameSceneDelegate {
    func gameSceneDidMoveToView(scene: GameScene, view: SKView) {
        if scene != pausedGameScene {
            Game.sharedInstance.configureLevel()
        }
    }
    
    func gameSceneDidFinishLevel(scene: GameScene, level: Level) {
        showLevel(level.index + 1)
    }
    
    func gameSceneDidPause(scene: GameScene) {
        self.pausedGameScene = scene
        
        MusicPlayer.sharedInstance.pause()
        
        showMainMenu(withAnimation: .Fade)
    }
}

// MARK: - LoadingSceneDelegate

extension SceneManager : LoadingSceneDelegate {
    func loadingSceneDidFinishLoading(scene: LoadingScene) {
        if Settings.showMenuOnStartupEnabled() {
            showMainMenu(withAnimation: .Fade)
        } else {
            showLevel(Settings.initialLevel())
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