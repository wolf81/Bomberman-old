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
    fileprivate (set) var options = [MenuOption]()
    fileprivate (set) var alignWithLastItem = false

    fileprivate var indicators = [Indicator]()
    fileprivate var labels = [SKLabelNode]()
    fileprivate var controls = [SKNode]()
    
    fileprivate var selectedOption: MenuOption?
    
    // MARK: - Initialization
    
    convenience init(size: CGSize, options: [MenuOption]) {
        self.init(size: size, options: options, alignWithLastItem: false)
    }
    
    init(size: CGSize, options: [MenuOption], alignWithLastItem: Bool) {
        super.init(size: size)
        
        self.alignWithLastItem = alignWithLastItem
        self.options = options
        
        selectedOption = options.first
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - View lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        updateUI()        
    }
    
    // MARK: - Private
    
    fileprivate func commonInit() {
        addLabelsAndControls()
        addIndicators()
        
        positionLabelsAndControls()
        positionIndicatorsForSelectionOption()
    }
    
    fileprivate func positionLabelsAndControls() {
        let x = size.width / 2
        let y = size.height / 2
        let padding: CGFloat = 30

        // Each label has 100 pixels in between the mid y positions. The labels are placed in the
        //  center of the view.
        let itemCountForHeight = fmaxf(Float(options.count - 1), 0)
        let totalHeight = CGFloat(itemCountForHeight * 100)
        let originY = y + (totalHeight / 2)
        
        for (idx, option) in options.enumerated().reversed() {
            let y = CGFloat(originY) - CGFloat(idx * 100)
            
            if let label = labelForMenuOption(option) {
                label.position = CGPoint(x: x, y: y)
                
                // When alignWithLastItem is set to true, we will align the last label in center 
                //  and other labels to the right. The other labels will be positioned accordingly 
                //  to be aligned with the last label.
                if alignWithLastItem && idx != (options.count - 1) {
                    if let lastLabel = labels.last {
                        let xOffset = lastLabel.calculateAccumulatedFrame().maxX - x
                        label.position = CGPoint(x: x + xOffset, y: y)
                    }
                    
                    label.horizontalAlignmentMode = .right
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
    
    fileprivate func positionIndicatorsForSelectionOption() {
        if let option = selectedOption {
            if let control = controlForMenuOption(option), control.parent != nil {
                if let label = labelForMenuOption(option) {
                    let minX = label.calculateAccumulatedFrame().minX
                    let maxX = control.calculateAccumulatedFrame().maxX
                    
                    let y = label.calculateAccumulatedFrame().minY
                    let labelHeight = label.calculateAccumulatedFrame().height
                    
                    if let leftIndicator = indicators.first {
                        let yOffset = (labelHeight - leftIndicator.size.height) / 2
                        
                        leftIndicator.alpha = 1.0
                        leftIndicator.position = CGPoint(x: minX - 35, y: y + yOffset)
                    }
                    
                    if let rightIndicator = indicators.last {
                        let yOffset = (labelHeight - rightIndicator.size.height) / 2
                        
                        rightIndicator.alpha = 1.0
                        rightIndicator.position = CGPoint(x: maxX + 25, y: y + yOffset)
                    }
                }
            } else {
                indicators.forEach({ indicator in indicator.alpha = 0.0 })
            }
        }
    }
    
    fileprivate func addLabelsAndControls() {
        for option in options {
            let label = SKLabelNode(text: option.title)
            addChild(label)
            labels.append(label)
            
            switch option.type {
            case .checkbox:
                let checkbox = Checkbox()
                let enabled = option.value as? Bool ?? false
                checkbox.enabled = enabled
                
                addChild(checkbox)
                controls.append(checkbox)
            case .numberChooser:
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
    
    fileprivate func addIndicators() {
        let leftIndicator = Indicator(direction: .left)
        addChild(leftIndicator)
        let rightIndicator = Indicator(direction: .right)
        addChild(rightIndicator)
        
        indicators = [leftIndicator, rightIndicator]
        
        positionIndicatorsForSelectionOption()
        
        indicators.forEach { indicator in indicator.runScaleAnimation(1.0, toValue: 0.85) }
    }
    
    fileprivate func updateUI() {
        let defaultFontName = "HelveticaNeue-UltraLight"
        let highlightFontName = "HelveticaNeue-Medium"
        
        for option in options {
            var fontName = defaultFontName

            if let selectedOption = self.selectedOption, option === selectedOption {
                fontName = highlightFontName
            }
            
            if let label = labelForMenuOption(option) {
                label.fontName = fontName
            }
        }
        
        focusControlForSelectedOption()
        positionIndicatorsForSelectionOption()
    }
    
    fileprivate func labelForMenuOption(_ option: MenuOption) -> SKLabelNode? {
        var label: SKLabelNode?
        
        for optionLabel in labels where optionLabel.text == option.title {
            label = optionLabel
        }
        
        return label
    }
    
    fileprivate func controlForMenuOption(_ option: MenuOption) -> SKNode? {
        let idx = indexOfMenuOption(option)
        return controls[idx]
    }
    
    fileprivate func indexOfMenuOption(_ option: MenuOption) -> Int {
        var idx = -1
        
        for (testIdx, testOption) in options.enumerated() {
            if testOption === option {
                idx = testIdx
            }
        }

        return idx
    }
    
    fileprivate func focusControlForSelectedOption() {        
        // First clear current focus by removing focus on all controls.
        for control in controls {
            if let focusableControl = control as? Focusable {
                focusableControl.setFocused(false)
            }
        }
        
        // Focus the control for the current label.
        if let option = selectedOption, let control = controlForMenuOption(option) {
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
                _ = option.update(value as AnyObject?)
            case let numberChooser as NumberChooser:
                let newValue = numberChooser.value - 1
                if option.update(newValue as AnyObject?) {
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
                _ = option.update(value as AnyObject?)
            case let numberChooser as NumberChooser:
                let newValue = numberChooser.value + 1
                if option.update(newValue as AnyObject?) {
                    numberChooser.value = newValue
                }
            default: break
            }
        }
    }

    override func handleUpPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in options.enumerated() {
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
        
        for (idx, option) in options.enumerated() {
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
