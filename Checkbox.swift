//
//  Switch.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/08/16.
//
//

import SpriteKit

class Checkbox: SKShapeNode, Focusable {
    var enabled = false {
        didSet {
            self.fillColor = enabled ? SKColor.whiteColor() : SKColor.clearColor()
        }
    }
    private var focused = false
    
    convenience override init() {
        self.init(size: CGSize(width: 18, height: 18))
    }
    
    init(size: CGSize) {
        super.init()
        
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPointZero, size: size), nil)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
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
    
    func toggle() -> Bool {
        self.enabled = !self.isEnabled()
        return self.enabled
    }
    
    // MARK: - Private
    
    func commonInit() {
        self.strokeColor = SKColor.whiteColor()
        self.fillColor = SKColor.whiteColor()
    }
}