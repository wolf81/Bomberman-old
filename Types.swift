//
//  Types.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 23/04/16.
//
//

import Foundation

struct EntityCategory {
    static let Nothing:     UInt32 = 0
    static let Monster:     UInt32 = 0b1
    static let Player:      UInt32 = 0b10
    static let Block:       UInt32 = 0b100
    static let Projectile:  UInt32 = 0b1000
    static let Prop:        UInt32 = 0b10000
    static let Wall:        UInt32 = 0b100000
    
    static func categoriesForStrings(strings: [String]) -> UInt32 {
        var bitMask = Nothing
        
        for (_, string) in strings.enumerate() {
            switch string {
            case "monster": bitMask |= Monster
            case "player": bitMask |= Player
            case "tile": bitMask |= Block
            case "projectile": bitMask |= Projectile
            case "prop": bitMask |= Prop
            case "wall": bitMask |= Wall
            default: break
            }
        }
        
        return bitMask
    }
}

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
    
    public init() {
        self.x = 0
        self.y = 0
    }
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

func pointEqualToPoint(point1: Point, _ point2: Point) -> Bool {
    return point1.x == point2.x && point1.y == point2.y
}

let unitLength: Int = 72