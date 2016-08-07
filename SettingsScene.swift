//
//  SettingsScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/07/16.
//
//

import SpriteKit

enum SettingsOption: Int {
    case Music = 0
    case Back
    
    static let allValues: [SettingsOption] = [Music, Back]
}

protocol SettingsSceneDelegate: SKSceneDelegate {
    func settingsScene(scene: SettingsScene, optionSelected: SettingsOption)
}

class SettingsScene: BaseScene {
    private var backLabel: SKLabelNode!
    private var musicLabel: SKLabelNode!
    
    // TODO: Should be an actual switch - for dev purposes we can use a label for now.
    private var musicSwitch: SKLabelNode!

    private var selectedOption: SettingsOption = .Music

    // Work around to set the subclass delegate.
    var settingsSceneDelegate: SettingsSceneDelegate? {
        get { return self.delegate as? SettingsSceneDelegate }
        set { self.delegate = newValue }
    }
    
    // MARK: - Initialization
    
    init(size: CGSize, delegate: SettingsSceneDelegate) {
        super.init(size: size)
        
        self.delegate = delegate
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - View lifecycle
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        updateUI()
    }
    
    // MARK: - Private
    
    private func commonInit() {
        let x = self.size.width / 2
        let y = self.size.height / 2
        
        self.backLabel = SKLabelNode(text: "BACK")
        self.backLabel.position = CGPoint(x: x, y: y - 50)
        self.addChild(self.backLabel)
        
        self.musicLabel = SKLabelNode(text: "MUSIC:")
        self.musicLabel.position = CGPoint(x: x, y: y + 50)
        self.addChild(self.musicLabel)
        
        let text = Settings.musicEnabled() ? "ON" : "OFF"
        self.musicSwitch = SKLabelNode(text: text)
        self.musicSwitch.position = CGPoint(x: x + 90, y: y + 50)
        self.addChild(self.musicSwitch)
    }
    
    private func updateUI() {
        let defaultFontName = "HelveticaNeue-UltraLight"
        let highlightFontName = "HelveticaNeue-Medium"
        
        for option in SettingsOption.allValues {
            let labels = labelForSettingsOption(option)
            labels.forEach({ label in
                label.fontName = (option == self.selectedOption) ? highlightFontName : defaultFontName
            })
        }
    }
    
    private func labelForSettingsOption(option: SettingsOption) -> [SKLabelNode] {
        var labels = [SKLabelNode]()
        
        switch option {
        case .Back: labels.append(self.backLabel)
        case .Music:
            labels.append(self.musicLabel)
            labels.append(self.musicSwitch)
        }
        
        return labels
    }
    
    // MARK: - Public
    
    override func handleUpPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in SettingsOption.allValues.enumerate() {
            if option == self.selectedOption {
                selectionIndex = max(idx - 1, 0)
                break
            }
        }
        
        self.selectedOption = SettingsOption(rawValue: selectionIndex)!
        
        updateUI()
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in SettingsOption.allValues.enumerate() {
            if option == self.selectedOption {
                selectionIndex = min(idx + 1, SettingsOption.allValues.count - 1)
                break
            }
        }
        
        self.selectedOption = SettingsOption(rawValue: selectionIndex)!
        
        updateUI()
    }

    override func handleActionPress(forPlayer player: PlayerIndex) {
        switch self.selectedOption {
        case .Back:
            self.settingsSceneDelegate?.settingsScene(self, optionSelected: self.selectedOption)
        case .Music:
            self.musicSwitch.text = (self.musicSwitch.text == "OFF") ? "ON" : "OFF"
            
            let enabled = self.musicSwitch.text == "ON"
            Settings.setMusicEnabled(enabled)
        }
    }
}