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

class Image: NSImage {}
    
extension NSImage {
    var CGImage: CGImageRef? {
        get {
            var imageRef: CGImageRef? = nil
            
            var imageRect:CGRect = CGRectMake(0, 0, self.size.width, self.size.height)
            imageRef = self.CGImageForProposedRect(&imageRect, context: nil, hints: nil)
            
            return imageRef
        }
    }
    
    class func imageWithColor(color: SKColor, size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatchInRect(NSMakeRect(0, 0, size.width, size.height))
        image.unlockFocus()
        return image
    }
}
    
#endif