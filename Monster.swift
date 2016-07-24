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
        
        self.value = PointsType.Hundred
        
        let cpuControlComponent = CpuControlComponent(game: game)
        addComponent(cpuControlComponent)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = EntityLayer.Monster.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Monster
                physicsBody.collisionBitMask = collidesWithPlayer ? EntityCategory.Player : EntityCategory.Nothing
                physicsBody.contactTestBitMask = collidesWithPlayer ? EntityCategory.Player : EntityCategory.Nothing
            }
        }
    }
}