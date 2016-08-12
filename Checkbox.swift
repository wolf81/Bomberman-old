//
//  Switch.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/08/16.
//
//

import SpriteKit

class Checkbox: SKShapeNode, Focusable {
    private var enabled = false
    private var focused = false
        
    init(size: CGSize) {
        super.init()
        
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPointZero, size: size), nil)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func setEnabled(enabled: Bool) {
        self.enabled = enabled        
        self.fillColor = enabled ? SKColor.whiteColor() : SKColor.clearColor()
    }
    
    func isEnabled() -> Bool {
        return self.enabled
    }
    
    func setFocused(focused: Bool) {
        self.focused = focused
        self.lineWidth = focused ? 2.0 : 1.0
    }
    
    func isFocused() -> Bool {
        return self.focused
    }
    
    func toggle() {
        let enabled = !self.isEnabled()
        setEnabled(enabled)
    }
    
    // MARK: - Private
    
    func commonInit() {
        self.strokeColor = SKColor.whiteColor()
        self.fillColor = SKColor.whiteColor()
    }
}