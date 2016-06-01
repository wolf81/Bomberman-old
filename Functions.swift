//
//  Functions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/05/16.
//
//

import Foundation
import CoreGraphics

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func positionForGridPosition(gridPosition: Point) -> CGPoint {
    let halfUnitLength = unitLength / 2
    let position = CGPoint(x: gridPosition.x * unitLength + halfUnitLength,
                           y: gridPosition.y * unitLength + halfUnitLength)
    return position
}

func gridPositionForPosition(position: CGPoint) -> Point {
    let x = Int(position.x / CGFloat(unitLength))
    let y = Int(position.y / CGFloat(unitLength))
    
    return Point(x: x, y: y)
}
