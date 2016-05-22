//
//  Monster.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/05/16.
//
//

import Foundation

class Monster: Creature {
    override init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        let cpuControlComponent = CpuControlComponent(game: game)
        addComponent(cpuControlComponent)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = 80
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = monsterCategory
                physicsBody.collisionBitMask = 0
                physicsBody.contactTestBitMask = 0
            }
        }
    }
}