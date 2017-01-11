//
//  Monster.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/05/16.
//
//

import Foundation

class Monster: Creature {
    
    // MARK: - Initialization
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, createPhysicsBody: Bool, collidesWithPlayer: Bool) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        value = PointsType.hundred
        
        let cpuControlComponent = CpuControlComponent(game: game)
        addComponent(cpuControlComponent)
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.zPosition = EntityLayer.monster.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Monster
                physicsBody.collisionBitMask = collidesWithPlayer ? EntityCategory.Player : EntityCategory.Nothing
                physicsBody.contactTestBitMask = collidesWithPlayer ? EntityCategory.Player | EntityCategory.Monster : EntityCategory.Monster
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
