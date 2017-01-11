//
//  Player.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/05/16.
//
//

import Foundation
import SpriteKit

class Player: Creature {
    let index: PlayerIndex
    
    fileprivate var shieldDuration: TimeInterval = 0
    fileprivate var moveSpeedDuration: TimeInterval = 0
    
    fileprivate let propLoader: PropLoader

    override var direction: Direction {
        set(newDirection) {
            super.direction = newDirection
            updateForDirection(self.direction)
        }
        get {
            return super.direction
        }
    }
        
    fileprivate(set) var explosionPowerLimit = PowerUpLimit(currentCount: 2, maxCount: 5)
    fileprivate(set) var bombTriggerPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    fileprivate(set) var shieldPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    fileprivate(set) var moveSpeedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    fileprivate(set) var bombPowerLimit = PowerUpLimit(currentCount: 4, maxCount: 6)
    fileprivate(set) var speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    
    // MARK: - Initialization
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, playerIndex: PlayerIndex) {
        index = playerIndex
        propLoader = PropLoader(forGame: game)
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)

        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.zPosition = EntityLayer.player.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Player
                physicsBody.contactTestBitMask = EntityCategory.Player
                physicsBody.collisionBitMask = EntityCategory.Nothing
            }
        }
        
        removeComponent(ofType: CpuControlComponent.self)
        
        let playerControlComponent = PlayerControlComponent(player: self)
        addComponent(playerControlComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if shieldPowerLimit.currentCount > 0 {
            shieldDuration -= seconds
            
            if shieldDuration < 0 {
                shieldPowerLimit.decrease {
                    self.updateForShield()
                }
            }
        }
        
        if moveSpeedPowerLimit.currentCount > 0 {
            moveSpeedDuration -= seconds
            
            if moveSpeedDuration < 0 {
                moveSpeedPowerLimit.decrease {
                    self.updateForMoveSpeed(speedAdjustment: 0.0)
                }
            }
        }
    }
    
    func addExplosionPower() {
        explosionPowerLimit.increase()
    }
    
    func addBombPower() {
        bombPowerLimit.increase()
    }
    
    func addBombTriggerPower() {
        bombTriggerPowerLimit.increase()
    }
    
    func addMoveSpeedPower(withDuration duration: TimeInterval) {
        moveSpeedPowerLimit.increase { 
            self.moveSpeedDuration = duration
            self.updateForMoveSpeed(speedAdjustment: 0.8)
        }
    }
    
    func addShieldPower(withDuration duration: TimeInterval) {
        shieldPowerLimit.increase() {
            self.shieldDuration = duration
            self.updateForShield()
        }
    }
    
    func dropBomb() throws -> Bool {
        var didDropBomb = false

        if let visualComponent = self.component(ofType: VisualComponent.self), let game = self.game, game.bombCountForPlayer(index) < self.bombPowerLimit.currentCount {

            let gridPosition = gridPositionForPosition(visualComponent.spriteNode.position)
            if game.bombAtGridPosition(gridPosition) == nil,
                let bomb = try propLoader.bombWithGridPosition(gridPosition, player: index) {
                bomb.range = explosionPowerLimit.currentCount
                bomb.spawnTimeAdjustment = -1 * Double(bombTriggerPowerLimit.currentCount) * 1
                game.addEntity(bomb)
                didDropBomb = true
            }
        }
        
        return didDropBomb
    }
    
    override func spawn() {
        resetPowerUps()
        
        if lives >= 0 {
            direction = .none
            addShieldPower(withDuration: 2.0)
            updateForShield()
            
            super.spawn()
        }
    }
    
    override func hit(_ damage: Int) {
        if shieldPowerLimit.currentCount == 0 {
            super.hit(damage)
        }
    }
    
    override func destroy() {
        if shieldPowerLimit.currentCount == 0 && !isDestroyed {
            health = 0
            resetPowerUps()

            game?.gameScene?.updateHudForPlayer(self)
            
            super.destroy()
        }
    }
    
    override func movementDirectionsFromCurrentGridPosition() -> [(direction: Direction, gridPosition: Point)] {
        var adjustedMovementDirections = [(direction: Direction, gridPosition: Point)]()
        
        var otherPlayer: Player
        
        switch self.index {
        case .player1: otherPlayer = game!.player2!
        case .player2: otherPlayer = game!.player1!
        }

        let movementDirections = super.movementDirectionsFromCurrentGridPosition()
        for direction in movementDirections {
            if pointEqualToPoint(direction.gridPosition, otherPlayer.gridPosition) && otherPlayer.isDestroyed == false {
                continue
            } else if pointEqualToPoint(direction.gridPosition, otherPlayer.nextGridPosition) && otherPlayer.isDestroyed == false {
                continue
            } else {
                adjustedMovementDirections.append(direction)
            }
        }
    
        return adjustedMovementDirections
    }
    
    override func updateForDirection(_ direction: Direction) {
        updateForShield()
    }

   // MARK: - Private
    
    fileprivate func decreasePowerUpLimitWhenExpired(_ powerUpLimit: inout PowerUpLimit, timeRemaining: TimeInterval = -1.0) -> Bool {
        var didDecrease = false
        
        if timeRemaining < 0 && powerUpLimit.currentCount > 0 {
            powerUpLimit.currentCount -= 1
            didDecrease = true
        }

        return didDecrease
    }
    
    // TODO: When hit by bullet after getting movement speed boost, speed is slowed down, even if 
    //  there is time remaining.
    fileprivate func updateForMoveSpeed(speedAdjustment adjustment: CGFloat) {
        if let visualComponent = component(ofType: VisualComponent.self),
            let configComponent = component(ofType: ConfigComponent.self) {
            visualComponent.spriteNode.speed = configComponent.speed + adjustment
        }
    }
    
    // TODO: When picking-up shield just after respawn, the full new shield should be added.
    fileprivate func updateForShield() {
        game?.gameScene?.updateHudForPlayer(self)
        
        // TODO 1: Clean-up the code for getting shield texture. Should be more dynamic,
        //  like entities. Perhaps the shield can be parsed as prop.
        //
        // TODO 2: Shield positioning seems wrong when respawning.
        if let visualComponent = component(ofType: VisualComponent.self) {
            if shieldPowerLimit.currentCount > 0 {
                let shieldTexture = SKTexture(imageNamed: "Shield.png")
                let spriteSize = CGSize(width: 32, height: 32)
                let shieldSprites = SpriteLoader.spritesFromTexture(shieldTexture, withSpriteSize: spriteSize)
                
                var shieldSprite: SKTexture
                
                switch direction {
                case .left: shieldSprite = shieldSprites[2]
                case .right: shieldSprite = shieldSprites[1]
                default: shieldSprite = shieldSprites[0]
                }

                if let shieldNode = visualComponent.spriteNode.childNode(withName: "shield") {
                    let updateTexture = SKAction.setTexture(shieldSprite)
                    shieldNode.run(updateTexture)
                    
                    if shieldDuration < 2.0 {
                        let fadeIn = SKAction.fadeAlpha(to: 0.0, duration: 0.5)
                        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
                        let fadeAnim = SKAction.sequence([fadeIn, fadeOut])
                        let anim = SKAction.repeatForever(fadeAnim)
                        shieldNode.run(anim)
                    }
                } else {
                    let shieldNode = SKSpriteNode(texture: shieldSprite, size: visualComponent.spriteNode.size)
                    shieldNode.name = "shield"
                    shieldNode.alpha = 0.5
                    shieldNode.zPosition = 1000
                    visualComponent.spriteNode.addChild(shieldNode)
                }
            } else {
                visualComponent.spriteNode.removeAllChildren()
            }
        }
    }
    
    fileprivate func resetPowerUps() {
        if lives >= 0 {
            explosionPowerLimit = PowerUpLimit(currentCount: 2, maxCount: 5)
            bombTriggerPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            moveSpeedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            shieldPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            bombPowerLimit = PowerUpLimit(currentCount: 4, maxCount: 6)
            speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
        } else {
            explosionPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 5)
            bombTriggerPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            moveSpeedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            shieldPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            bombPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 6)
            speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
        }
    }
}
