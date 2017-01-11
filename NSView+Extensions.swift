//
//  NSView+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 11/08/16.
//
//


#if os(OSX)

import Cocoa

extension NSView {
    func fadeOut(_ duration: TimeInterval, completion: @escaping () -> Void) {
        assert(self.layer != nil, "Make sure wantsLayer is set to true. This animation happens on the layer of the view.")
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1.0
        fadeOut.toValue = 0.0
        fadeOut.duration = duration
        self.layer?.add(fadeOut, forKey: nil)
        self.layer?.opacity = 0.0
        
        CATransaction.commit()
    }
    
    func fadeIn(_ duration: TimeInterval, completion: @escaping () -> Void) {
        assert(self.layer != nil, "Make sure wantsLayer is set to true. This animation happens on the layer of the view.")

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = duration
        self.layer?.add(fadeIn, forKey: nil)
        self.layer?.opacity = 1.0

        CATransaction.commit()
    }
}

#endif

