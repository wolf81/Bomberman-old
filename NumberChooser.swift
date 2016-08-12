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
    private(set) var value: Int = 0
    
    var defaultFontName: String = "HelveticaNeue-UltraLight"
    var highlightFontName: String = "HelveticaNeue-Medium"
    
    var minValue: Int = 0
    var maxValue: Int = Int.max
    
    init(initialValue: Int) {
        super.init()
        
        self.value = initialValue
        self.text = String(self.value)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - Private
    
    private func commonInit() {
        updateForFocus()
    }
    
    private func updateForFocus() {
        self.fontName = self.focused ? highlightFontName : defaultFontName
    }
    
    // MARK: - Focusable
    
    func setFocused(focused: Bool) {
        self.focused = focused
        
        updateForFocus()
    }
    
    func isFocused() -> Bool {
        return self.focused
    }
    
    // MARK: - Public
    
    
    func increase() -> Int {
        self.value = min(self.value + 1, self.maxValue)
        self.text = String(self.value)
        return self.value
    }
    
    func decrease() -> Int {
        self.value = max(self.value - 1, self.minValue)
        self.text = String(self.value)
        return self.value
    }
}