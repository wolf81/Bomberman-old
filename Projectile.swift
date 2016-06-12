//
//  Projectile.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import Foundation

class Projectile: Entity {
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = EntityLayer.Projectile.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Projectile
                physicsBody.contactTestBitMask = EntityCategory.Player | EntityCategory.Tile
                physicsBody.collisionBitMask = EntityCategory.Player | EntityCategory.Tile
                physicsBody.usesPreciseCollisionDetection = true;
            }
        }
    }    
}