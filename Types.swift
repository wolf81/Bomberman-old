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
    
    static func categoriesForStrings(_ strings: [String]) -> UInt32 {
        var bitMask = Nothing
        
        for (_, string) in strings.enumerated() {
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
    case none
    case up
    case down
    case left
    case right
    case action
    case pause
}

@objc public enum Direction: Int {
    case none
    case up
    case down
    case right
    case left
}

@objc public enum PlayerIndex: Int {
    case player1
    case player2
}

public enum TileType: Int {
    case none                   = 0
    case wall                   = 1
    case destructableBlock      = 2
    case indestructableBlock    = 3
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

func pointEqualToPoint(_ point1: Point, _ point2: Point) -> Bool {
    return point1.x == point2.x && point1.y == point2.y
}

let unitLength: Int = 72
