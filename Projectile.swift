//
//  Projectile.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import CoreGraphics

class Projectile: Entity {
    var force = CGVector()
    
    var damage: Int {
        var damage = 1
        
        if let configComponent = componentForClass(ConfigComponent) {
            // TODO: check for explicit animation action, cause just sounds are also possible
            damage = configComponent.hitDamage
        }
        
        return damage
    }
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = EntityLayer.Projectile.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Projectile
                physicsBody.contactTestBitMask = EntityCategory.Player | EntityCategory.Tile
                physicsBody.collisionBitMask = EntityCategory.Player | EntityCategory.Tile
                physicsBody.usesPreciseCollisionDetection = true;
                physicsBody.linearDamping = 0.0;
            }
        }
    }    
}