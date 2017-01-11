//
//  Functions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/05/16.
//
//

import Foundation
import CoreGraphics

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func positionForGridPosition(_ gridPosition: Point) -> CGPoint {
    let halfUnitLength = unitLength / 2
    let position = CGPoint(x: gridPosition.x * unitLength + halfUnitLength,
                           y: gridPosition.y * unitLength + halfUnitLength)
    return position
}

func gridPositionForPosition(_ position: CGPoint) -> Point {
    let x = Int(position.x / CGFloat(unitLength))
    let y = Int(position.y / CGFloat(unitLength))
    
    return Point(x: x, y: y)
}
