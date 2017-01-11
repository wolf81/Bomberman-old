//
//  Image.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 28/04/16.
//
//

import Foundation
import SpriteKit

#if os(tvOS)

import UIKit
    
class Image: UIImage {}
    
extension UIImage {
    class func imageWithColor(color: SKColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
    
#else
    
import AppKit

class Image: NSImage {
    override public init(size: NSSize) {
        super.init(size: size)
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    required init?(pasteboardPropertyList propertyList: Any, ofType type: String) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
}
    
extension NSImage {
    var CGImage: CGImage? {
        get {
            var imageRef: CGImage? = nil
            
            var imageRect:CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            imageRef = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
            
            return imageRef
        }
    }
    
    class func imageWithColor(_ color: SKColor, size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
        image.unlockFocus()
        return image
    }
}
    
#endif
