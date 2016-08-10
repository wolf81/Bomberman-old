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
    
    // MARK: - Public
    
    override func handleUpPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, item) in self.options.enumerate() {
            if item === self.selectedOption {
                selectionIndex = max(idx - 1, 0)
                break
            }
        }
        
        self.selectedOption = self.options[selectionIndex]
        
        updateUI()
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, item) in self.options.enumerate() {
            if item === self.selectedOption {
                selectionIndex = min(idx + 1, self.options.count - 1)
                break
            }
        }
        
        self.selectedOption = self.options[selectionIndex]
        
        updateUI()
    }
    
    override func handleActionPress(forPlayer player: PlayerIndex) {
        if let selectedItem = self.selectedOption {
            self.menuSceneDelegate?.menuScene(self, optionSelected: selectedItem)
        }
    }
}