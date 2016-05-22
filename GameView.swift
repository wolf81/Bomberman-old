//
//  GameView.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 22/04/16.
//
//

import SpriteKit

class GameView: SKView {
    
    #if os(tvOS)
    
    override init(frame frameRect: CGRect) {
        super.init(frame:frameRect)
        
        commonInit()
    }
    
    #else
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonInit()
    }

    override func viewWillMoveToSuperview(newSuperview: NSView?) {
        if let view = newSuperview {
            frame = view.bounds
        }
    }

    #endif
    
    required init?(coder: NSCoder) {
        return nil
    }

    func commonInit() {
        #if os(tvOS)
        #else
        self.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        #endif
        
        self.showsFPS = true
        self.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.ignoresSiblingOrder = true
    }
}