//
//  Projectile.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import Foundation

class Projectile: Entity {
    var direction = Direction.None
    
    override init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = 100
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = projectileCategory
                physicsBody.contactTestBitMask = playerCategory | tileCategory
                physicsBody.collisionBitMask = nothingCategory
                physicsBody.usesPreciseCollisionDetection = true;
            }
        }
    }    
}