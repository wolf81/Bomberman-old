//
//  Switch.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/08/16.
//
//

import SpriteKit

class Switch: SKShapeNode {
    private var enabled = false
    
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
    
    // MARK: - Private
    
    func commonInit() {
        self.lineWidth = 4.0
        self.strokeColor = SKColor.whiteColor()
        self.fillColor = SKColor.whiteColor()
    }
}