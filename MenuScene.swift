//
//  MainMenuScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 09/05/16.
//
//

import SpriteKit

protocol MenuSceneDelegate: SKSceneDelegate {
    func menuScene(scene: MenuScene, optionSelected: MenuOption)
}

class MenuScene: BaseScene {
    var options = [MenuOption]()
    var optionLabels = [SKLabelNode]()
    var controls = [SKNode]()
    
    private var selectedOption: MenuOption?
    
    // Work around to set the subclass delegate.
    var menuSceneDelegate: MenuSceneDelegate? {
        get { return self.delegate as? MenuSceneDelegate }
        set { self.delegate = newValue }
    }
    
    // MARK: - Initialization
    
    init(size: CGSize, delegate: MenuSceneDelegate, options: [MenuOption]) {
        super.init(size: size)
        
        self.delegate = delegate
                
        self.options = options
        self.selectedOption = options.first
        
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
        
        MusicPlayer.sharedInstance.pause()
    }
    
    // MARK: - Private
    
    private func commonInit() {
        let x = self.size.width / 2
        let y = self.size.height / 2
        
        let itemCountForHeight = fmaxf(Float(self.options.count - 1), 0)
        let totalHeight = CGFloat(itemCountForHeight * 100)
        let originY = y + (totalHeight / 2)
        
        var optionLabels = [SKLabelNode]()
        for (idx, item) in options.enumerate() {
            let label = SKLabelNode(text: item.title)
            let y = CGFloat(originY) - CGFloat(idx * 100)
            label.position = CGPoint(x: x, y: y)
            self.addChild(label)
            optionLabels.append(label)
            
            if item.type == .Switch {
                let switchSize = CGSize(width: 18, height: 18)
                let optionSwitch = Switch(size: switchSize)
                let labelFrame = label.calculateAccumulatedFrame()
                let yOffset = (labelFrame.size.height - switchSize.height) / 2
                let xOffset: CGFloat = 30 // TODO: calc using back button half size
                let padding: CGFloat = 20
                optionSwitch.position = CGPoint(x: x + xOffset + padding, y: y + yOffset)

                if let enabled = item.value as? Bool {
                    optionSwitch.setEnabled(enabled)
                }
                self.addChild(optionSwitch)
                self.controls.append(optionSwitch)
            }
        }
        self.optionLabels = optionLabels
    }
    
    private func updateUI() {
        let defaultFontName = "HelveticaNeue-UltraLight"
        let highlightFontName = "HelveticaNeue-Medium"
        
        for item in self.options {
            var fontName = defaultFontName

            if let selectedItem = self.selectedOption {
                if item === selectedItem {
                    fontName = highlightFontName
                }
            }
            
            if let label = labelForMenuOption(item) {
                label.fontName = fontName
            }
        }
        
        focusControlForSelectedOption()
    }
    
    private func labelForMenuOption(option: MenuOption) -> SKLabelNode? {
        var label: SKLabelNode?
        
        for optionLabel in self.optionLabels {
            if optionLabel.text == option.title {
                label = optionLabel
            }
        }
        
        return label
    }
    
    private func controlForMenuOption(option: MenuOption) -> SKNode? {
        var controlForOption: SKNode?
        
        let label = labelForMenuOption(option)
        
        for control in self.controls {
            var yRange = 0 ..< 0
            if let labelFrame = label?.calculateAccumulatedFrame() {
                yRange = Int(labelFrame.minY) ..< Int(labelFrame.maxY)
            }
            
            if yRange.contains(Int(control.position.y)) {
                controlForOption = control
                break
            }
        }
        
        return controlForOption
    }
    
    private func toggleSwitch(optionSwitch: Switch) {
        let enabled = !optionSwitch.isEnabled()
        optionSwitch.setEnabled(enabled)
    }
    
    private func focusControlForSelectedOption() {
        // First clear selection
        for control in self.controls {
            if let optionSwitch = control as? Switch {
                optionSwitch.setFocused(false)
            }
        }
        
        // Focus the correct control for the current label
        if let option = self.selectedOption, control = controlForMenuOption(option) {
            switch option.type {
            case .Switch:
                if let optionSwitch = control as? Switch {
                    optionSwitch.setFocused(true)
                }
            default: break
            }
        }
    }
    
    // MARK: - Public
    
    override func handleLeftPress(forPlayer player: PlayerIndex) {
        for option in self.options {
            if option === selectedOption {
                let control = controlForMenuOption(option)
                
                switch option.type {
                case .Switch: if let optionSwitch = control as? Switch { toggleSwitch(optionSwitch) }
                default: break
                }
            }
        }
    }
    
    override func handleRightPress(forPlayer player: PlayerIndex) {
        for option in self.options {
            if option === selectedOption {
                let control = controlForMenuOption(option)
                
                switch option.type {
                case .Switch: if let optionSwitch = control as? Switch { toggleSwitch(optionSwitch) }
                default: break
                }
            }
        }
    }

    override func handleUpPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in self.options.enumerate() {
            if option === self.selectedOption {
                selectionIndex = max(idx - 1, 0)
                break
            }
        }
        
        self.selectedOption = self.options[selectionIndex]
        
        updateUI()
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in self.options.enumerate() {
            if option === self.selectedOption {
                selectionIndex = min(idx + 1, self.options.count - 1)
                break
            }
        }
        
        self.selectedOption = self.options[selectionIndex]
        
        updateUI()
    }
    
    override func handleActionPress(forPlayer player: PlayerIndex) {
        if let selectedOption = self.selectedOption {
            self.menuSceneDelegate?.menuScene(self, optionSelected: selectedOption)
        }
    }
}