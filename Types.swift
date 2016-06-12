//
//  Types.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 23/04/16.
//
//

import Foundation

let monsterCategory     : UInt32 = 0x1 << 0
let playerCategory      : UInt32 = 0x1 << 1
let tileCategory        : UInt32 = 0x1 << 2
let projectileCategory  : UInt32 = 0x1 << 3
let propCategory        : UInt32 = 0x1 << 4
let nothingCategory     : UInt32 = 0x1 << 5

@objc public enum PlayerAction: Int {
    case None
    case Up
    case Down
    case Left
    case Right
    case Action
    case Pause
}

@objc public enum Direction: Int {
    case None
    case Up
    case Down
    case Right
    case Left
}

@objc public enum PlayerIndex: Int {
    case Player1
    case Player2
}

public enum TileType: Int {
    case None                   = 0
    case Wall                   = 1
    case DestructableBlock      = 2
    case IndestructableBlock    = 3
}

public struct Size {
    var width: Int
    var height: Int
}

public struct Point {
    var x: Int
    var y: Int
}

func pointEqualToPoint(point1: Point, point2: Point) -> Bool {
    return point1.x == point2.x && point1.y == point2.y
}

let unitLength: Int = 72