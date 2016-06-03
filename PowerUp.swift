//
//  Power.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/05/16.
//
//

import SpriteKit

enum PowerType: Int {
    case ExplosionSize = 0
    case Unknown
}

class PowerUp: Entity {
    private(set) var activated = false
    private(set) var power: PowerType
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, power: PowerType) {
        self.power = power
        
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
    
    func activate(forPlayer player: Player) {
        if self.activated == false {
            self.activated = true
            
            switch self.power {
            case .ExplosionSize: player.abilityRange += 1
            default: break
            }
        }
    }
}