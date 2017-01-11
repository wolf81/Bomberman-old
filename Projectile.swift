//
//  Projectile.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import CoreGraphics
import Foundation

class Projectile: Entity {
    var damage: Int {
        var damage = 1
        
        if let configComponent = component(ofType: ConfigComponent.self) {
            // TODO: check for explicit animation action, cause just sounds are also possible
            damage = configComponent.hitDamage
        }
        
        return damage
    }
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, force: CGVector = CGVector()) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.zPosition = EntityLayer.projectile.rawValue

            if let configComponent = component(ofType: ConfigComponent.self) {
                if let physicsBody = visualComponent.spriteNode.physicsBody {
                    physicsBody.categoryBitMask = EntityCategory.Projectile
                    physicsBody.usesPreciseCollisionDetection = true;
                    physicsBody.linearDamping = 0.0;
                    
                    let bitMask = configComponent.collisionCategories
                    physicsBody.contactTestBitMask = bitMask
                    physicsBody.collisionBitMask = bitMask
                    
                    let velocity = CGVector(dx: force.dx * speed, dy: force.dy * speed)
                    physicsBody.velocity = velocity
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clone() -> Projectile {
        let game = self.game!
        let configComponent = component(ofType: ConfigComponent.self)!
        
        return Projectile(forGame: game, configComponent: configComponent, gridPosition: Point(x: 0, y: 0))
    }
}
