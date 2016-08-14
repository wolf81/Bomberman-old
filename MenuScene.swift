//
//  MainMenuScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 09/05/16.
//
//

/*
 * A scene that can be used for creating game menus. A scene is configured using a list of menu 
 * options. The default menu option type generates a simple 'button' (basically a label that can be 
 * clicked). For other menu option types a label and control is generated. The value of the control 
 * can be changed by pressing left and right buttons.
 */

import SpriteKit

class MenuScene: BaseScene {
    private (set) var options = [MenuOption]()
    private (set) var alignWithLastItem = false

    private var indicators = [Indicator]()
    private var labels = [SKLabelNode]()
    private var controls = [SKNode]()
    
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
    }
    
    // MARK: - Private
    
    private func commonInit() {
        addLabelsAndControls()
        addIndicators()
        
        positionLabelsAndControls()
        positionIndicatorsForSelectionOption()
    }
    
    private func positionLabelsAndControls() {
        let x = self.size.width / 2
        let y = self.size.height / 2
        let padding: CGFloat = 30

        // Each label has 100 pixels in between the mid y positions. The labels are placed in the
        //  center of the view.
        let itemCountForHeight = fmaxf(Float(self.options.count - 1), 0)
        let totalHeight = CGFloat(itemCountForHeight * 100)
        let originY = y + (totalHeight / 2)
        
        for (idx, option) in self.options.enumerate().reverse() {
            let y = CGFloat(originY) - CGFloat(idx * 100)
            
            if let label = labelForMenuOption(option) {
                label.position = CGPoint(x: x, y: y)
                
                // When alignWithLastItem is set to true, we will align the last label in center 
                //  and other labels to the right. The other labels will be positioned accordingly 
                //  to be aligned with the last label.
                if alignWithLastItem && idx != (self.options.count - 1) {
                    if let lastLabel = self.labels.last {
                        let xOffset = lastLabel.calculateAccumulatedFrame().maxX - x
                        label.position = CGPoint(x: x + xOffset, y: y)
                    }
                    
                    label.horizontalAlignmentMode = .Right
                }
            }
            
            // Positioning of controls is much easier. We can just look at the maximum x position 
            //  of the current label and add some padding.
            if let control = controlForMenuOption(option) {
                var labelFrame = CGRect()
                
                if let label = labelForMenuOption(option) {
                    labelFrame = label.calculateAccumulatedFrame()
                }
                
                let controlSize = control.calculateAccumulatedFrame().size
                let yOffset = (labelFrame.size.height - controlSize.height) / 2
                control.position = CGPoint(x: labelFrame.maxX + padding, y: y + yOffset)
            }
        }
    }
    
    private func positionIndicatorsForSelectionOption() {
        if let option = selectedOption {
            if let control = controlForMenuOption(option) where control.parent != nil {
                if let label = labelForMenuOption(option) {
                    let minX = label.calculateAccumulatedFrame().minX
                    let maxX = control.calculateAccumulatedFrame().maxX
                    
                    var y = label.calculateAccumulatedFrame().minY
                    let labelHeight = label.calculateAccumulatedFrame().height
                    
                    if let leftIndicator = indicators.first {
                        y += (labelHeight - leftIndicator.calculateAccumulatedFrame().height) / 2
                        
                        leftIndicator.alpha = 1.0
                        leftIndicator.position = CGPoint(x: minX - 50, y: y)
                    }
                    
                    if let rightIndicator = indicators.last {
                        y += (labelHeight - rightIndicator.calculateAccumulatedFrame().height) / 2
                        
                        rightIndicator.alpha = 1.0
                        rightIndicator.position = CGPoint(x: maxX + 30, y: y)
                    }
                }
            } else {
                for indicator in indicators {
                    indicator.alpha = 0.0
                }
            }
        }
    }
    
    private func addLabelsAndControls() {
        for option in self.options {
            let label = SKLabelNode(text: option.title)
            addChild(label)
            labels.append(label)
            
            switch option.type {
            case .Checkbox:
                let checkbox = Checkbox()
                let enabled = option.value as? Bool ?? false
                checkbox.enabled = enabled
                
                addChild(checkbox)
                controls.append(checkbox)
            case .NumberChooser:
                let value = option.value as? Int ?? 0
                let chooser = NumberChooser(initialValue: value)
                
                addChild(chooser)
                controls.append(chooser)
            default:
                // We use a dummy control in the controls list so we can use the same index as the
                //  index of it's label.
                let dummyControl = SKNode()
                controls.append(dummyControl)
            }
        }
    }
    
    private func addIndicators() {
        let leftIndicator = Indicator(direction: .Left)
        addChild(leftIndicator)
        let rightIndicator = Indicator(direction: .Right)
        addChild(rightIndicator)
        
        indicators = [leftIndicator, rightIndicator]
        
        positionIndicatorsForSelectionOption()
    }
    
    private func updateUI() {
        let defaultFontName = "HelveticaNeue-UltraLight"
        let highlightFontName = "HelveticaNeue-Medium"
        
        for option in options {
            var fontName = defaultFontName

            if let selectedOption = self.selectedOption where option === selectedOption {
                fontName = highlightFontName
            }
            
            if let label = labelForMenuOption(option) {
                label.fontName = fontName
            }
        }
        
        focusControlForSelectedOption()
        positionIndicatorsForSelectionOption()
    }
    
    private func labelForMenuOption(option: MenuOption) -> SKLabelNode? {
        var label: SKLabelNode?
        
        for optionLabel in labels where optionLabel.text == option.title {
            label = optionLabel
        }
        
        return label
    }
    
    private func controlForMenuOption(option: MenuOption) -> SKNode? {
        let idx = indexOfMenuOption(option)
        return controls[idx]
    }
    
    private func indexOfMenuOption(option: MenuOption) -> Int {
        var idx = -1
        
        for (testIdx, testOption) in options.enumerate() {
            if testOption === option {
                idx = testIdx
            }
        }

        return idx
    }
    
    private func focusControlForSelectedOption() {        
        // First clear current focus by removing focus on all controls.
        for control in controls {
            if let focusableControl = control as? Focusable {
                focusableControl.setFocused(false)
            }
        }
        
        // Focus the control for the current label.
        if let option = selectedOption, control = controlForMenuOption(option) {
            if let focusableControl = control as? Focusable {
                focusableControl.setFocused(true)
            }
        }
    }
    
    // MARK: - Public
    
    override func handleLeftPress(forPlayer player: PlayerIndex) {
        for option in options where option === selectedOption {
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
        for option in options where option === selectedOption {
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
        
        for (idx, option) in options.enumerate() {
            if option === selectedOption {
                selectionIndex = max(idx - 1, 0)
                break
            }
        }
        
        selectedOption = options[selectionIndex]
        
        updateUI()
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in options.enumerate() {
            if option === selectedOption {
                selectionIndex = min(idx + 1, options.count - 1)
                break
            }
        }
        
        selectedOption = options[selectionIndex]
        
        updateUI()
    }
    
    override func handleActionPress(forPlayer player: PlayerIndex) {
        if let option = selectedOption {
            if let onSelected = option.onSelected {
                onSelected()
            }
        }
    }
}