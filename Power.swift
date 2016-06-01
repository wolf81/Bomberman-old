//
//  Power.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/05/16.
//
//

import SpriteKit

class Power: Entity {
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: true)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = 15
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = propCategory
                physicsBody.collisionBitMask = nothingCategory
                physicsBody.contactTestBitMask = playerCategory
            }
        }
    }    
}