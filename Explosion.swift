//
//  Explosion.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 01/05/16.
//
//

import Foundation

class Explosion: Entity {
    
    // MARK: - Initialization
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.zPosition = EntityLayer.explosion.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Prop
                physicsBody.collisionBitMask = EntityCategory.Nothing
                physicsBody.contactTestBitMask = EntityCategory.Player | EntityCategory.Monster
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func destroy() {
        removePhysicsBody()
        
        super.destroy()
    }
}
