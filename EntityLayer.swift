//
//  EntityLayer.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 09/06/16.
//
//

import CoreGraphics

// zPositions of entities.
enum EntityLayer: CGFloat {
    case bomb = 1
    case explosion
    case tile
    case prop
    case powerUp
    case monster
    case projectile
    case player
    case points
}
