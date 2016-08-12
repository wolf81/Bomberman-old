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
    private var musicSwitch: Checkbox!
    
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
        let padding: CGFloat = 30
        
        self.backLabel = SKLabelNode(text: "BACK")
        self.backLabel.position = CGPoint(x: x, y: y - 50)
        self.addChild(self.backLabel)
        
        let xOffset = self.backLabel.calculateAccumulatedFrame().maxX - x
        print("xOffset: \(xOffset)")

        self.musicLabel = SKLabelNode(text: "PLAY MUSIC")
        self.musicLabel.position = CGPoint(x: x + xOffset, y: y + 50)
        self.musicLabel.horizontalAlignmentMode = .Right
        self.addChild(self.musicLabel)
        
        let enabled = Settings.musicEnabled()
        let switchSize = CGSize(width: 18, height: 18)
        self.musicSwitch = Checkbox(size: switchSize)
        let labelFrame = self.musicLabel.calculateAccumulatedFrame()
        let yOffset = (labelFrame.size.height - switchSize.height) / 2
        self.musicSwitch.position = CGPoint(x: x + xOffset + padding, y: y + 50 + yOffset)
        self.musicSwitch.enabled = enabled
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
        
        self.musicSwitch.setFocused(self.selectedOption == .Music)
    }
    
    private func labelForSettingsOption(option: SettingsOption) -> [SKLabelNode] {
        var labels = [SKLabelNode]()
        
        switch option {
        case .Back: labels.append(self.backLabel)
        case .Music:
            labels.append(self.musicLabel)
        }
        
        return labels
    }
    
    private func toggleMusicSwitch() -> Bool {
        let enabled = !self.musicSwitch.isEnabled()
        self.musicSwitch.enabled = enabled
        return enabled
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
    
    override func handleLeftPress(forPlayer player: PlayerIndex) {
        switch self.selectedOption {
        case .Music:
            let enabled = toggleMusicSwitch()
            Settings.setMusicEnabled(enabled)
        default: break
        }
    }
    
    override func handleRightPress(forPlayer player: PlayerIndex) {
        switch self.selectedOption {
        case .Music:
            let enabled = toggleMusicSwitch()
            Settings.setMusicEnabled(enabled)
        default: break
        }
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
        default:
            break
        }
    }
}