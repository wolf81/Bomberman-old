//
//  NumberChooser.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 11/08/16.
//
//

import SpriteKit

class NumberChooser : SKLabelNode, Focusable {
    private var focused = false
    
    var value: Int = 0 {
        didSet {
            self.text = String(self.value)
        }
    }
    
    var defaultFontName: String = "HelveticaNeue-UltraLight"
    var highlightFontName: String = "HelveticaNeue-Medium"
    
    var minValue: Int = Int.min
    var maxValue: Int = Int.max
    
    init(initialValue: Int) {
        super.init()
        
        value = initialValue
        text = String(self.value)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - Private
    
    private func commonInit() {
        horizontalAlignmentMode = .Left
        
        updateForFocus()
    }
    
    private func updateForFocus() {
        fontName = focused ? highlightFontName : defaultFontName
    }
    
    // MARK: - Focusable
    
    func setFocused(focused: Bool) {
        self.focused = focused
        
        updateForFocus()
    }
    
    func isFocused() -> Bool {
        return self.focused
    }    
}