//
//  EntityLayer.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 09/06/16.
//
//

import Foundation

// zPositions of entities.
enum EntityLayer: CGFloat {
    case Bomb = 1
    case Explosion
    case Tile
    case Prop
    case PowerUp
    case Monster
    case Projectile
    case Player
    case Points
}