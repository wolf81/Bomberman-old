//
//  SettingsScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/07/16.
//
//

import SpriteKit

enum SettingsOption: Int {
    case Back = 0
    
    static let allValues: [SettingsOption] = [Back]
}

protocol SettingsSceneDelegate: SKSceneDelegate {
    func settingsScene(scene: SettingsScene, optionSelected: SettingsOption)
}

class SettingsScene: BaseScene {
    private var backLabel: SKLabelNode!

    private var selectedOption: SettingsOption = .Back

    // Work around to set the subclass delegate.
    var settingsSceneDelegate: SettingsSceneDelegate? {
        get { return self.delegate as? SettingsSceneDelegate }
        set { self.delegate = newValue }
    }
    
    // MARK: - Initialization
    
    init(size: CGSize, delegate: MenuSceneDelegate) {
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
        
        self.backLabel = SKLabelNode(text: "Back")
        self.backLabel.position = CGPoint(x: x, y: y + 150)
        self.addChild(self.backLabel)
    }
    
    private func updateUI() {
        let defaultFontName = "HelveticaNeue-UltraLight"
        let highlightFontName = "HelveticaNeue-Medium"
        
        for option in SettingsOption.allValues {
            let label = labelForSettingsOption(option)
            label.fontName = option == self.selectedOption ? highlightFontName : defaultFontName
        }
    }
    
    private func labelForSettingsOption(option: SettingsOption) -> SKLabelNode {
        var label: SKLabelNode
        
        switch option {
        case .Back: label = self.backLabel
        }
        
        return label
    }
    
    override func handleActionPress(forPlayer player: PlayerIndex) {
        self.settingsSceneDelegate?.settingsScene(self, optionSelected: self.selectedOption)
    }
}