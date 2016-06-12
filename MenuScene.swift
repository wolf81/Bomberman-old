//
//  MainMenuScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 09/05/16.
//
//

import SpriteKit

enum MenuOption: Int {
    case NewGame = 0
    case Continue
    case Settings
    case Developer
    
    static let allValues: [MenuOption] = [NewGame, Continue, Settings, Developer]
}

protocol MenuSceneDelegate: SKSceneDelegate {
    func menuScene(scene: MenuScene, optionSelected: MenuOption)
}

class MenuScene: BaseScene {
    private var newGameLabel: SKLabelNode!
    private var continueGameLabel: SKLabelNode!
    private var settingsLabel: SKLabelNode!
    private var developerLabel: SKLabelNode!
    
    private var selectedOption: MenuOption = .NewGame
    
    // Work around to set the subclass delegate.
    var menuSceneDelegate: MenuSceneDelegate? {
        get { return self.delegate as? MenuSceneDelegate }
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
        
        self.newGameLabel = SKLabelNode(text: "NEW GAME")
        self.newGameLabel.position = CGPoint(x: x, y: y + 150)
        self.addChild(self.newGameLabel)
        
        self.continueGameLabel = SKLabelNode(text: "CONTINUE")
        self.continueGameLabel.position = CGPoint(x: x, y: y + 50)
        self.addChild(self.continueGameLabel)
        
        self.settingsLabel = SKLabelNode(text: "SETTINGS")
        self.settingsLabel.position = CGPoint(x: x, y: y - 50)
        self.addChild(self.settingsLabel)
        
        self.developerLabel = SKLabelNode(text: "DEVELOPER")
        self.developerLabel.position = CGPoint(x: x, y: y - 150)
        self.addChild(self.developerLabel)
    }
    
    private func updateUI() {
        let defaultFontName = "HelveticaNeue-UltraLight"
        let highlightFontName = "HelveticaNeue-Medium"
        
        for option in MenuOption.allValues {
            let label = labelForMenuOption(option)
            label.fontName = option == self.selectedOption ? highlightFontName : defaultFontName
        }
    }
    
    private func labelForMenuOption(option: MenuOption) -> SKLabelNode {
        var label: SKLabelNode
        
        switch option {
        case .Continue: label = self.continueGameLabel
        case .Developer: label = self.developerLabel
        case .NewGame: label = self.newGameLabel
        case .Settings: label = self.settingsLabel
        }
        
        return label
    }
    
    // MARK: - Public
    
    override func handleUpPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in MenuOption.allValues.enumerate() {
            if option == self.selectedOption {
                selectionIndex = max(idx - 1, 0)
                break
            }
        }
        
        self.selectedOption = MenuOption(rawValue: selectionIndex)!
        
        updateUI()
    }
    
    override func handleDownPress(forPlayer player: PlayerIndex) {
        var selectionIndex = 0
        
        for (idx, option) in MenuOption.allValues.enumerate() {
            if option == self.selectedOption {
                selectionIndex = min(idx + 1, MenuOption.allValues.count - 1)
                break
            }
        }
        
        self.selectedOption = MenuOption(rawValue: selectionIndex)!
        
        updateUI()
    }
    
    override func handleActionPress(forPlayer player: PlayerIndex) {
        self.menuSceneDelegate?.menuScene(self, optionSelected: self.selectedOption)
    }
}