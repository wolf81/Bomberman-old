//
//  SKTexture+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 28/04/16.
//
//

import SpriteKit

#if os(tvOS)
    
import UIKit

extension SKTexture {
    
    func tiledTextureWithSize(size: CGSize, tileSize: CGSize) -> SKTexture {
        UIGraphicsBeginImageContext(tileSize);
        var context = UIGraphicsGetCurrentContext();
        CGContextDrawTiledImage(context, CGRect(x: 0, y:0, width: tileSize.width, height: tileSize.height), self.CGImage());
        let tileImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let color = SKColor(patternImage: tileImage)
        let rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 2);
        context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let texture = SKTexture(image: image)
        
        return texture
    }
}

#else
    
import AppKit

extension SKTexture {

    func tiledTextureWithSize(size: CGSize, tileSize: CGSize) -> SKTexture {
        let tileImage = NSImage(CGImage: self.CGImage(), size: tileSize)
        
        // stretch tile image to actual tile size
        let adjustedTileImage = NSImage(size: tileSize)
        adjustedTileImage.lockFocus()
        tileImage.drawInRect(NSRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height))
        adjustedTileImage.unlockFocus()
        
        // create a new tiled background image
        let tiledImage = NSImage(size: size)
        tiledImage.lockFocus()
        SKColor(patternImage: adjustedTileImage).set()
        NSBezierPath.fillRect(NSRect(x: 0, y: 0, width: size.width, height: size.height))
        tiledImage.unlockFocus()

        let texture = SKTexture(image: tiledImage)
        
        return texture
    }
}

#endif