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

// TODO: Consider adding a protocol shared between tvOS and macOS. So we can build against an 
//  interface, not a class, which can / will differ between tvOS and macOS.

// TODO: Using notifications here might be ugly, but it's the best solution I can think of for now. 

import Foundation

// MARK: - tvOS -

#if os(tvOS)

import UIKit
    
class InfoOverlay: UIView {

}
    
#else

// MARK: - macOS -

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
        label.frame = frame
    }
    
    // MARK: - Private
    
    fileprivate func commonInit() {
        label = NSTextView()
        label.backgroundColor = NSColor.clear
        label.font = NSFont.systemFont(ofSize: 16)
        label.textColor = NSColor.white
        label.wantsLayer = true
        addSubview(label)
        
        autoresizingMask = .viewWidthSizable
        
        wantsLayer = true
        layer?.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        layer?.opacity = 0.0
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "net.wolftrail.bomberman.message"), object: nil, queue: OperationQueue.current, using: { notification in
            if let message = notification.object as? String {
                self.update(message)
            }
        })
    }
        
    // MARK: - Public
    
    func update(_ text: String) {
        if isUpdating {
            return
        }
        
        isUpdating = true
        
        label.string = text
        
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

func updateInfoOverlayWithMessage(_ message: String) {
    let notification = Notification(name: Notification.Name(rawValue: "net.wolftrail.bomberman.message"), object: message)
    NotificationCenter.default.post(notification)
}
