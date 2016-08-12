//
//  MainMenuScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 09/05/16.
//
//

import SpriteKit

class MenuScene: BaseScene {
    var options = [MenuOption]()
    var labels = [SKLabelNode]()
    var controls = [SKNode]()
    var alignWithLastItem = false
    
    private var selectedOption: MenuOption?
    
    // MARK: - Initialization
    
    convenience init(size: CGSize, options: [MenuOption]) {
        self.init(size: size, options: options, alignWithLastItem: false)
    }
    
    init(size: CGSize, options: [MenuOption], alignWithLastItem: Bool) {
        super.init(size: size)
        
        self.delegate = delegate
        self.alignWithLastItem = alignWithLastItem
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
        self.labels = [SKLabelNode]()

        addLabelsAndControls()
        positionLabelsAndControls()
    }
    
    private func positionLabelsAndControls() {
        let x = self.size.width / 2
        let y = self.size.height / 2
        
        let itemCountForHeight = fmaxf(Float(self.options.count - 1), 0)
        let totalHeight = CGFloat(itemCountForHeight * 100)
        let originY = y + (totalHeight / 2)
        let padding: CGFloat = 30
        
        for (idx, option) in self.options.enumerate().reverse() {
            let y = CGFloat(originY) - CGFloat(idx * 100)
            
            if let label = labelForMenuOption(option) {
                label.position = CGPoint(x: x, y: y)
                
                if alignWithLastItem && idx != (self.options.count - 1) {
                    if let lastLabel = self.labels.last {
                        let xOffset = lastLabel.calculateAccumulatedFrame().maxX - x
                        label.position = CGPoint(x: x + xOffset, y: y)
                    }
                    
                    label.horizontalAlignmentMode = .Right
                }
            }
            
            if let control = controlForMenuOption(option) {
                var labelFrame = CGRect()
                
                if let label = labelForMenuOption(option) {
                    labelFrame = label.calculateAccumulatedFrame()
                }
                
                let controlSize = control.calculateAccumulatedFrame().size
                let x = labelFrame.maxX
                let yOffset = (labelFrame.size.height - controlSize.height) / 2
                control.position = CGPoint(x: x + padding, y: y + yOffset)
            }
        }
    }
    
    private func addLabelsAndControls() {
        for option in self.options {
            let label = SKLabelNode(text: option.title)
            self.addChild(label)
            self.labels.append(label)
            
            switch option.type {
            case .Checkbox:
                let checkbox = Checkbox()
                let enabled = option.value as? Bool ?? false
                checkbox.enabled = enabled
                
                self.addChild(checkbox)
                self.controls.append(checkbox)
            case .NumberChooser:
                let value = option.value as? Int ?? 0
                let chooser = NumberChooser(initialValue: value)
                
                self.addChild(chooser)
                self.controls.append(chooser)
            default:
                // We use a dummy control in the controls list so we can use the same index as the
                //  index of it's label.
                let dummyControl = SKNode()
                self.controls.append(dummyControl)
            }
        }
    }
    
    private func updateUI() {
        let defaultFontName = "HelveticaNeue-UltraLight"
        let highlightFontName = "HelveticaNeue-Medium"
        
        for item in self.options {
            var fontName = defaultFontName

            if let selectedItem = self.selectedOption where item === selectedItem {
                fontName = highlightFontName
            }
            
            if let label = labelForMenuOption(item) {
                label.fontName = fontName
            }
        }
        
        focusControlForSelectedOption()
    }
    
    private func labelForMenuOption(option: MenuOption) -> SKLabelNode? {
        var label: SKLabelNode?
        
        for optionLabel in self.labels where optionLabel.text == option.title {
            label = optionLabel
        }
        
        return label
    }
    
    private func controlForMenuOption(option: MenuOption) -> SKNode? {
        let idx = indexOfMenuOption(option)
        return self.controls[idx]
    }
    
    private func indexOfMenuOption(option: MenuOption) -> Int {
        var idx = -1
        
        for (testIdx, testOption) in self.options.enumerate() {
            if testOption === option {
                idx = testIdx
            }
        }

        return idx
    }
    
    private func focusControlForSelectedOption() {        
        // First clear current focus by removing focus on all controls.
        for control in self.controls {
            if let focusableControl = control as? Focusable {
                focusableControl.setFocused(false)
            }
        }
        
        // Focus the control for the current label.
        if let option = self.selectedOption, control = controlForMenuOption(option) {
            if let focusableControl = control as? Focusable {
                focusableControl.setFocused(true)
            }
        }
    }
    
    // MARK: - Public
    
    override func handleLeftPress(forPlayer player: PlayerIndex) {
        for option in self.options where option === selectedOption {
            let control = controlForMenuOption(option)
            
            switch control {
            case let checkbox as Checkbox:
                let value = checkbox.toggle()
                option.update(value)
            case let numberChooser as NumberChooser:
                let newValue = numberChooser.value - 1
                if option.update(newValue) {
                    numberChooser.value = newValue
                }
            default: break
            }
        }
    }
    
    override func handleRightPress(forPlayer player: PlayerIndex) {
        for option in self.options where option === selectedOption {
            let control = controlForMenuOption(option)
            
            switch control {
            case let checkbox as Checkbox:
                let value = checkbox.toggle()
                option.update(value)
            case let numberChooser as NumberChooser:
                let newValue = numberChooser.value + 1
                if option.update(newValue) {
                    numberChooser.value = newValue
                }
            default: break
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
            if let onSelected = selectedOption.onSelected {
                onSelected()
            }
        }
    }
}