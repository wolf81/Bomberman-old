//
//  Power.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/05/16.
//
//

import SpriteKit

enum PowerType: Int {
    case explosionSize = 0
    case healAll
    case heal
    case bombAdd
    case bombSpeed
    case moveSpeed
    case shield
    case destroyMonsters
    case destroyBlocks
    case unknown
}

class PowerUp: Entity {
    fileprivate(set) var destroyDelay: TimeInterval = 8.0
    fileprivate(set) var activated = false
    fileprivate(set) var power: PowerType
    
    // MARK: - Initialization
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, power: PowerType) {
        self.power = power
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: true)
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.zPosition = EntityLayer.powerUp.rawValue
            
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
    
    // MARK: - Public
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        destroyDelay -= seconds
        
        if destroyDelay <= 0 {
            destroy()
        }
    }
    
    func activate(forPlayer player: Player) {
        if activated == false {
            activated = true
            
            switch self.power {
            case .explosionSize:
                player.addExplosionPower()
            case .heal:
                player.health += 4
            case .healAll:
                player.health = 16
            case .bombAdd:
                player.addBombPower()
            case .bombSpeed:
                player.addBombTriggerPower()
            case .shield:
                player.addShieldPower(withDuration: 10.0)
            case .moveSpeed:
                player.addMoveSpeedPower(withDuration: 15.0)
            case .destroyBlocks:
                game?.tiles.filter({ (tile) -> Bool in
                    tile.tileType != .wall && tile.tileType != .indestructableBlock
                }).forEach({ $0.destroy() })
            case .destroyMonsters:
                game?.creatures
                    .filter({ $0 is Monster })
                    .forEach({ $0.destroy() })
            default: break
            }
        }
    }
}
