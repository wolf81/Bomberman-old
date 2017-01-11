//
//  SceneController.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 01/06/16.
//
//

import SpriteKit

enum TransitionAnimation {
    case fade
    case push
    case pop
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
    
    fileprivate func showMainMenu(withAnimation animation: TransitionAnimation) {
        let menuScene = MenuScene(size: self.defaultSize, options: mainMenuOptions())
        self.transitionToScene(menuScene, animation: animation)
    }
    
    fileprivate func showSubMenuWithOptions(_ options: [MenuOption]) {
        let scene = MenuScene(size: defaultSize, options: options, alignWithLastItem: true)
        transitionToScene(scene, animation: .push)
    }
    
    fileprivate func showLevel(_ levelIndex: Int) {
        do {
            let level = try loadLevel(levelIndex)
            let scene = GameScene(level: level, gameSceneDelegate: self)
            Game.sharedInstance.configureForGameScene(scene)
            transitionToScene(scene, animation: .fade)
        } catch let error {
            updateInfoOverlayWithMessage("\(error)")
            print("error: \(error)")
            
            showMainMenu(withAnimation: .fade)
        }
    }
    
    fileprivate func continueLevel() {
        if let scene = pausedGameScene {
            transitionToScene(scene, animation: .fade)            
            Game.sharedInstance.resume()
        }
    }
    
    fileprivate func transitionToScene(_ scene: BaseScene, animation: TransitionAnimation) {
        var transition: SKTransition
        
        let duration = 0.5
        
        switch animation {
        case .fade:
            transition = SKTransition.fade(withDuration: duration)
        case .push:
            transition = SKTransition.push(with: SKTransitionDirection.left, duration: duration)
        case .pop:
            transition = SKTransition.push(with: SKTransitionDirection.right, duration: duration)
        }
        
        self.gameViewController?.presentScene(scene, withTransition: transition)
        
        InputProxy.sharedInstance.autoDirectionPressRelease = !(scene is GameScene)
        InputProxy.sharedInstance.scene = scene
    }

    fileprivate func loadLevel(_ levelIndex: Int) throws -> Level {
        let levelParser = LevelLoader(forGame: Game.sharedInstance)
        let level = try levelParser.loadLevel(levelIndex)
        return level
    }
}

// MARK: - Menu Options

extension SceneManager {
    fileprivate func settingsOptions() -> [MenuOption] {
        let backItem = MenuOption(title: "BACK") {
            self.showMainMenu(withAnimation: .pop)
        }
        
        let enabled = Settings.musicEnabled()
        let playMusicItem = MenuOption(title: "PLAY MUSIC", type: .checkbox, value: enabled as AnyObject?) { newValue in
            if let enabled = newValue as? Bool {
                Settings.setMusicEnabled(enabled)
            }
        }
        
        return [playMusicItem, backItem]
    }
    
    fileprivate func developerOptions() -> [MenuOption] {
        let backItem = MenuOption(title: "BACK") {
            self.showMainMenu(withAnimation: .pop)
        }
        
        let levelIdx = Settings.initialLevel()
        let initialLevelItem = MenuOption(title: "INITIAL LEVEL", type: .numberChooser, value: levelIdx as AnyObject?) { newValue in
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
        let checkAssetsItem = MenuOption(title: "CHECK ASSETS ON START-UP", type: .checkbox, value: checkAssets as AnyObject?) { newValue in
            if let enabled = newValue as? Bool {
                Settings.setAssetsCheckEnabled(enabled)
            }
        }
        
        let showMenu = Settings.showMenuOnStartupEnabled()
        let showMenuOnStartUpItem = MenuOption(title: "SHOW MENU ON START-UP", type: .checkbox, value: showMenu as AnyObject?) { newValue in
            if let enabled = newValue as? Bool {
                Settings.setShowMenuOnStartupEnabled(enabled)
            }
        }
        
        return [initialLevelItem, checkAssetsItem, showMenuOnStartUpItem, backItem]
    }
    
    fileprivate func mainMenuOptions() -> [MenuOption] {
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
    func gameSceneDidMoveToView(_ scene: GameScene, view: SKView) {
        if scene != pausedGameScene {
            Game.sharedInstance.configureLevel()
        }
    }
    
    func gameSceneDidFinishLevel(_ scene: GameScene, level: Level) {
        showLevel(level.index + 1)
    }
    
    func gameSceneDidPause(_ scene: GameScene) {
        self.pausedGameScene = scene
        
        MusicPlayer.sharedInstance.pause()
        
        showMainMenu(withAnimation: .fade)
    }
}

// MARK: - LoadingSceneDelegate

extension SceneManager : LoadingSceneDelegate {
    func loadingSceneDidFinishLoading(_ scene: LoadingScene) {
        if Settings.showMenuOnStartupEnabled() {
            showMainMenu(withAnimation: .fade)
        } else {
            showLevel(Settings.initialLevel())
        }
    }
    
    func loadingSceneDidMoveToView(_ scene: LoadingScene, view: SKView) {
        do {
            try scene.updateAssetsIfNeeded()
        } catch let error {
            print("error: \(error)")
        }
    }
}
