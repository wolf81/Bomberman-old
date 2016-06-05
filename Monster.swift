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
    
    override init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        self.value = PointsType.Hundred
        
        let cpuControlComponent = CpuControlComponent(game: game)
        addComponent(cpuControlComponent)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = 80
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = monsterCategory
                physicsBody.collisionBitMask = nothingCategory
                physicsBody.contactTestBitMask = nothingCategory
            }
        }
    }
}