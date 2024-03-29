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
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.zPosition = EntityLayer.prop.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Prop
                physicsBody.collisionBitMask = EntityCategory.Nothing
                physicsBody.contactTestBitMask = EntityCategory.Player
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
