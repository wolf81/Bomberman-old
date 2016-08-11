//
//  InfoOverlay.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 11/08/16.
//
//

/*
 * A view that can be shows status info for the game. 
 *
 * TODO (low prio, this is just for debug info, not gameplay):
 * - Add a queue of messages
 * - Create 2 labels, one for the current status message, one for the next.
 * - When the queue has more than 1 status message, set the next message to the next label and start
 *   a fake scroll animation for both labels. The labels scroll up. Once the first label is out of
 *   view, make it replace the second label. Place second label back to bottom for the next message.
 * - When no more messages in queue, fade out.
 * - When a message is added to empty queue, fade in.
 */

import Foundation

// MARK: - tvOS -

#if os(tvOS)

import UIKit
    
class InfoOverlay: UIView {

}
    
#else

// MARK: - OS X -

import Cocoa

class InfoOverlay: NSView {
    var label: NSTextView!
    var isUpdating = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override func layout() {
        super.layout()
        
        let inset: CGFloat = 5.0
        let frame = NSInsetRect(self.bounds, inset, inset)
        self.label.frame = frame
    }
    
    // MARK: - Private
    
    private func commonInit() {
        self.label = NSTextView()
        self.label.backgroundColor = NSColor.clearColor()
        self.label.font = NSFont.systemFontOfSize(16)
        self.label.textColor = NSColor.whiteColor()
        self.label.wantsLayer = true
        addSubview(self.label)
        
        self.autoresizingMask = .ViewWidthSizable
        
        self.wantsLayer = true
        
        self.layer?.backgroundColor = CGColorCreateGenericRGB(0, 0, 0, 1.0)
        self.layer?.opacity = 0.0
        
        update("Bla die bla bla")
    }
        
    // MARK: - Public
    
    func update(text: String) {
        if self.isUpdating {
            return
        }
        
        self.isUpdating = true
        
        self.label.string = text
        
        fadeIn(0.5, completion: { 
            delay(2.0) {
                self.fadeOut(0.5, completion: { 
                    self.isUpdating = false
                })
            }
        })
    }
}
    
#endif