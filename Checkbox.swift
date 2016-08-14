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
            fillColor = enabled ? SKColor.whiteColor() : SKColor.clearColor()
        }
    }
    private var focused = false
    
    convenience override init() {
        self.init(size: CGSize(width: 18, height: 18))
    }
    
    init(size: CGSize) {
        super.init()
        
        path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPointZero, size: size), nil)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func isEnabled() -> Bool {
        return enabled
    }
    
    func setFocused(focused: Bool) {
        self.focused = focused
        
        lineWidth = focused ? 2.0 : 1.0
    }
    
    func isFocused() -> Bool {
        return focused
    }
    
    func toggle() -> Bool {
        enabled = !isEnabled()
        return enabled
    }
    
    // MARK: - Private
    
    func commonInit() {
        strokeColor = SKColor.whiteColor()
        fillColor = SKColor.whiteColor()
    }
}