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
    private(set) var destroyDelay: NSTimeInterval = 8.0
    private(set) var activated = false
    private(set) var power: PowerType
    
    // MARK: - Initialization
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, power: PowerType) {
        self.power = power
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: true)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = EntityLayer.PowerUp.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = propCategory
                physicsBody.collisionBitMask = nothingCategory
                physicsBody.contactTestBitMask = playerCategory
            }
        }
    }
    
    // MARK: - Public
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        self.destroyDelay -= seconds
        
        if destroyDelay <= 0 {
            self.destroy()
        }
    }
    
    func activate(forPlayer player: Player) {
        if self.activated == false {
            self.activated = true
            
            switch self.power {
            case .ExplosionSize:
                player.addExplosionPower()
            case .Heal:
                player.health += 4
            case .HealAll:
                player.health = 16
            case .BombAdd:
                player.addBombPower()
            case .BombSpeed:
                player.addBombTriggerPower()
            case .Shield:
                player.addShieldPower(withDuration: 10.0)
            case .MoveSpeed:
                player.addMoveSpeedPower(withDuration: 15.0)
            case .DestroyBlocks:
                self.game?.tiles.forEach({ $0.destroy() })
            case .DestroyMonsters:
                self.game?.creatures
                    .filter({ $0 is Monster })
                    .forEach({ $0.destroy() })
            default: break
            }
        }
    }
}