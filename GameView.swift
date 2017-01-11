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

    override func viewWillMove(toSuperview newSuperview: NSView?) {
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
        self.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        #endif
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.ignoresSiblingOrder = true
        self.shouldCullNonVisibleNodes = true
//        self.showsPhysics = true
    }
}
