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
    case HealAll
    case Heal
    case BombAdd
    case BombSpeed
    case MoveSpeed
    case Shield
    case DestroyMonsters
    case DestroyBlocks
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
            case .Heal: player.health += 4
            case .HealAll: player.health = 16
            case .DestroyBlocks:                
                if let tiles = self.game?.tiles {
                    for tile in tiles {
                        tile.destroy()
                    }
                }
            case .DestroyMonsters:
                if let creatures = self.game?.creatures {
                    for creature in creatures {
                        if creature is Monster {
                            creature.destroy()
                        }
                    }
                }
            default: break
            }
        }
    }
}