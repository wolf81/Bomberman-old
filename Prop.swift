//
//  Prop.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 06/05/16.
//
//

import Foundation

class Prop: Entity {
    
    // MARK: - Initialization

    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = 1
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = propCategory
                physicsBody.collisionBitMask = nothingCategory
                physicsBody.contactTestBitMask = playerCategory
            }
        }
    }
}