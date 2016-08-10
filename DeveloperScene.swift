//
//  DeveloperScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/07/16.
//
//

import SpriteKit

enum DeveloperOption: Int {
    case Level
    case AssetsCheck
    case Back
    
    static let allValues: [DeveloperOption] = [Level, AssetsCheck, Back]
}

protocol DeveloperSceneDelegate: SKSceneDelegate {
    func developerScene(scene: DeveloperScene, optionSelected: DeveloperOption)
}

class DeveloperScene: BaseScene {
    private var levelLabel: SKLabelNode!
    private var backLabel: SKLabelNode!
    private var assetsCheckLabel: SKLabelNode!
    
    // TODO: Create proper controls
    private var levelChooser: SKLabelNode!
    private var assetsCheckSwitch: Switch!
    
    private var selectedOption: DeveloperOption = .Level
    
    // Work around to set the subclass delegate.
    var developerSceneDelegate: DeveloperSceneDelegate? {
        get { return self.delegate as? DeveloperSceneDelegate }
        set { self.delegate = newValue }
    }
    
    // MARK: - Initialization
    
    init(size: CGSize, delegate: DeveloperSceneDelegate) {
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
        self.backLabel.position = CGPoint(x: x, y: y - 100)
        self.backLabel.horizontalAlignmentMode = .Center
        self.addChild(self.backLabel)

        let xOffset = self.backLabel.calculateAccumulatedFrame().maxX - x
        
        self.levelLabel = SKLabelNode(text: "INITIAL LEVEL")
        self.levelLabel.position = CGPoint(x: x + xOffset, y: y + 100)
        self.levelLabel.horizontalAlignmentMode = .Right
        self.addChild(self.levelLabel)
        
        let index = Settings.initialLevel()
        self.levelChooser = SKLabelNode(text: "\(index)")
        self.levelChooser.position = CGPoint(x: x + xOffset + padding, y: y + 100)
        self.levelChooser.horizontalAlignmentMode = .Left
        self.addChild(self.levelChooser)
        
        self.assetsCheckLabel = SKLabelNode(text: "CHECK ASSETS ON START-UP")
        self.assetsCheckLabel.position = CGPoint(x: x + xOffset, y: y)
        self.assetsCheckLabel.horizontalAlignmentMode = .Right
        self.addChild(self.assetsCheckLabel)
        
        let enabled = Settings.assetsCheckEnabled()
        let switchSize = CGSize(width: 18, height: 18)
        self.assetsCheckSwitch = Switch(size: switchSize)
        let labelFrame = self.assetsCheckLabel.calculateAccumulatedFrame()
        let yOffset = (labelFrame.size.height - switchSize.height) / 2
        self.assetsCheckSwitch.position = CGPoint(x: x + xOffset + padding, y: y + yOffset)
        self.assetsCheckSwitch.setEnabled(enabled)
        self.addChild(self.assetsCheckSwitch)
        
        print("frame: \(labelFrame) switchSize: \(switchSize)")
    }
    
    private func updateUI() {
        let defaultFontName = "HelveticaNeue-UltraLight"
        let highlightFontName = "HelveticaNeue-Medium"
        
        for option in DeveloperOption.allValues {
            let labels = labelsForDeveloperOption(option)
            labels.forEach({ label in
                label.fontName = (option == self.selectedOption) ? highlightFontName : defaultFontName
            })
        }
        
        self.assetsCheckSwitch.setFocused(self.selectedOption == .AssetsCheck)
    }
    
    private func labelsForDeveloperOption(option: DeveloperOption) -> [SKLabelNode] {
        var labels = [SKLabelNode]()
        
        switch option {
        case .Level:
            labels.append(self.levelLabel)
            labels.append(self.levelChooser)
        case .AssetsCheck:
            labels.append(self.assetsCheckLabel)
        case .Back:
            labels.append(self.backLabel)
        }
        
        return labels
    }
        
    // MARK: - Public
    
    override func handleUpPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in DeveloperOption.allValues.enumerate() {
            if option == self.selectedOption {
                selectionIndex = max(idx - 1, 0)
                break
            }
        }
        
        self.selectedOption = DeveloperOption(rawValue: selectionIndex)!
        
        updateUI()
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in DeveloperOption.allValues.enumerate() {
            if option == self.selectedOption {
                selectionIndex = min(idx + 1, DeveloperOption.allValues.count - 1)
                break
            }
        }
        
        self.selectedOption = DeveloperOption(rawValue: selectionIndex)!
        
        updateUI()
    }
    
    override func handleLeftPress(forPlayer player: PlayerIndex) {
        switch self.selectedOption {
        case .Level:
            let index = decrementLevelChooser()
            Settings.setInitialLevel(index)
        case .AssetsCheck:
            let enabled = toggleAssetsCheckSwitch()
            Settings.setAssetsCheckEnabled(enabled)
        default: break
        }
    }
    
    override func handleRightPress(forPlayer player: PlayerIndex) {
        switch self.selectedOption {
        case .Level:
            let index = incrementLevelChooser()
            Settings.setInitialLevel(index)
        case .AssetsCheck:
            let enabled = toggleAssetsCheckSwitch()
            Settings.setAssetsCheckEnabled(enabled)
        default: break
        }
    }
    
    override func handleActionPress(forPlayer player: PlayerIndex) {
        switch self.selectedOption {
        case .Back:
            self.developerSceneDelegate?.developerScene(self, optionSelected: self.selectedOption)
        default:
            break
        }
    }
    
    // MARK: - Private
    
    private func incrementLevelChooser() -> Int {
        var index = Int(self.levelChooser.text!)!
        let maxIndex = max(LevelLoader.levelCount - 1, 0)
        index = min(index + 1, maxIndex)
        self.levelChooser.text = String(index)
        return index
    }
    
    private func decrementLevelChooser() -> Int {
        var index = Int(self.levelChooser.text!)!
        index = max(index - 1, 0)
        self.levelChooser.text = String(index)
        return index
    }
    
    private func toggleAssetsCheckSwitch() -> Bool {
        let enabled = !self.assetsCheckSwitch.isEnabled()
        self.assetsCheckSwitch.setEnabled(enabled)
        return enabled
    }
    
    private func selectedLevelIndex() -> Int {
        let index = Int(self.levelChooser.text!)!
        return index
    }
}