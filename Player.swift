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
    
    private var shieldDuration: NSTimeInterval = 0
    private var moveSpeedDuration: NSTimeInterval = 0
    
    private let propLoader: PropLoader

    override var direction: Direction {
        set(newDirection) {
            super.direction = newDirection
            updateForDirection(self.direction)
        }
        get {
            return super.direction
        }
    }
        
    private(set) var explosionPowerLimit = PowerUpLimit(currentCount: 2, maxCount: 5)
    private(set) var bombTriggerPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    private(set) var shieldPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    private(set) var moveSpeedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    private(set) var bombPowerLimit = PowerUpLimit(currentCount: 4, maxCount: 6)
    private(set) var speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    
    // MARK: - Initialization
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, playerIndex: PlayerIndex) {
        self.index = playerIndex
        self.propLoader = PropLoader(forGame: game)
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)

        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = EntityLayer.Player.rawValue
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = EntityCategory.Player
                physicsBody.contactTestBitMask = EntityCategory.Player
                physicsBody.collisionBitMask = EntityCategory.Nothing
            }
        }
        
        removeComponentForClass(CpuControlComponent)
        
        let playerControlComponent = PlayerControlComponent(player: self)
        addComponent(playerControlComponent)
    }
    
    // MARK: - Public
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if self.shieldPowerLimit.currentCount > 0 {
            self.shieldDuration -= seconds
            
            if self.shieldDuration < 0 && self.shieldPowerLimit.currentCount > 0 {
                self.shieldPowerLimit.currentCount -= 1
                updateForShield()
            }
        }
        
        if self.moveSpeedPowerLimit.currentCount > 0 {
            self.moveSpeedDuration -= seconds
            
            if self.moveSpeedDuration < 0 && self.moveSpeedPowerLimit.currentCount > 0 {
                self.moveSpeedPowerLimit.currentCount -= 1
                updateForMoveSpeed(speedAdjustment: 0.0)
            }
        }        
    }
    
    func addExplosionPower() {
        if self.explosionPowerLimit.currentCount < self.explosionPowerLimit.maxCount {
            self.explosionPowerLimit.currentCount += 1
        }
    }
    
    func addBombPower() {
        if self.bombPowerLimit.currentCount < self.bombPowerLimit.maxCount {
            self.bombPowerLimit.currentCount += 1
        }
    }
    
    func addBombTriggerPower() {
        if self.bombTriggerPowerLimit.currentCount < self.bombTriggerPowerLimit.maxCount {
            self.bombTriggerPowerLimit.currentCount += 1
        }
    }
    
    func addMoveSpeedPower(withDuration duration: NSTimeInterval) {
        if self.moveSpeedPowerLimit.currentCount < self.moveSpeedPowerLimit.maxCount {
            self.moveSpeedPowerLimit.currentCount += 1
            self.moveSpeedDuration = duration
            
            updateForMoveSpeed(speedAdjustment: 0.8)
        }
    }
    
    func addShieldPower(withDuration duration: NSTimeInterval) {
        if self.shieldPowerLimit.currentCount < self.shieldPowerLimit.maxCount {
            self.shieldPowerLimit.currentCount += 1
            self.shieldDuration = duration
            
            updateForShield()
        }
    }
    
    func dropBomb() throws -> Bool {
        var didDropBomb = false

        if self.game?.bombCountForPlayer(self.index) < self.bombPowerLimit.currentCount  {
            if let game = self.game, let visualComponent = self.componentForClass(VisualComponent) {
                let gridPosition = gridPositionForPosition(visualComponent.spriteNode.position)
                if game.bombAtGridPosition(gridPosition) == nil {
                    if let bomb = try self.propLoader.bombWithGridPosition(gridPosition, player: self.index) {
                        bomb.range = self.explosionPowerLimit.currentCount
                        bomb.spawnTimeAdjustment = -1 * Double(self.bombTriggerPowerLimit.currentCount) * 1
                        game.addEntity(bomb)
                        didDropBomb = true
                    }
                }
            }
        }
        
        return didDropBomb
    }
    
    override func spawn() {
        resetPowerUps()
        
        if self.lives >= 0 {
            self.direction = .None
            self.addShieldPower(withDuration: 2.0)
            updateForShield()
            
            super.spawn()
        }
    }
    
    override func hit(damage: Int) {
        if self.shieldPowerLimit.currentCount == 0 {
            super.hit(damage)
        }
    }
    
    override func destroy() {
        if self.shieldPowerLimit.currentCount == 0 && !self.isDestroyed {
            self.health = 0
            self.resetPowerUps()

            self.game?.gameScene?.updateHudForPlayer(self)
            
            super.destroy()
        }
    }
    
    override func movementDirectionsFromCurrentGridPosition() -> [(direction: Direction, gridPosition: Point)] {
        var adjustedMovementDirections = [(direction: Direction, gridPosition: Point)]()
        
        var otherPlayer: Player
        
        switch self.index {
        case .Player1: otherPlayer = self.game!.player2!
        case .Player2: otherPlayer = self.game!.player1!
        }

        let movementDirections = super.movementDirectionsFromCurrentGridPosition()
        for direction in movementDirections {
            if pointEqualToPoint(direction.gridPosition, point2: otherPlayer.gridPosition) && otherPlayer.isDestroyed == false{
                continue
            } else if pointEqualToPoint(direction.gridPosition, point2: otherPlayer.nextGridPosition) && otherPlayer.isDestroyed == false {
                continue
            } else {
                adjustedMovementDirections.append(direction)
            }
        }
    
        return adjustedMovementDirections
    }
    
    override func updateForDirection(direction: Direction) {
        updateForShield()
    }

   // MARK: - Private

    // TODO: When hit by bullet after getting movement speed boost, speed is slowed down, even if 
    //  there is time remaining.
    private func updateForMoveSpeed(speedAdjustment adjustment: CGFloat) {
        if let visualComponent = componentForClass(VisualComponent),
            configComponent = componentForClass(ConfigComponent) {
            visualComponent.spriteNode.speed = configComponent.speed + adjustment
        }
    }
    
    // TODO: When picking-up shield just after respawn, the full new shield should be added.
    private func updateForShield() {
        self.game?.gameScene?.updateHudForPlayer(self)
        
        // TODO 1: Clean-up the code for getting shield texture. Should be more dynamic,
        //  like entities. Perhaps the shield can be parsed as prop.
        //
        // TODO 2: Shield positioning seems wrong when respawning.
        if let visualComponent = componentForClass(VisualComponent) {
            if self.shieldPowerLimit.currentCount > 0 {
                let shieldTexture = SKTexture(imageNamed: "Shield.png")
                let spriteSize = CGSizeMake(32, 32)
                let shieldSprites = SpriteLoader.spritesFromTexture(shieldTexture, withSpriteSize: spriteSize)
                
                var shieldSprite: SKTexture
                
                switch self.direction {
                case .Left: shieldSprite = shieldSprites[2]
                case .Right: shieldSprite = shieldSprites[1]
                default: shieldSprite = shieldSprites[0]
                }

                if let shieldNode = visualComponent.spriteNode.childNodeWithName("shield") {
                    let updateTexture = SKAction.setTexture(shieldSprite)
                    shieldNode.runAction(updateTexture)
                    
                    if shieldDuration < 2.0 {
                        let fadeIn = SKAction.fadeAlphaTo(0.0, duration: 0.5)
                        let fadeOut = SKAction.fadeAlphaTo(0.5, duration: 0.5)
                        let fadeAnim = SKAction.sequence([fadeIn, fadeOut])
                        let anim = SKAction.repeatActionForever(fadeAnim)
                        shieldNode.runAction(anim)
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
    
    private func resetPowerUps() {
        if self.lives >= 0 {
            self.explosionPowerLimit = PowerUpLimit(currentCount: 2, maxCount: 5)
            self.bombTriggerPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            self.moveSpeedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            self.shieldPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            self.bombPowerLimit = PowerUpLimit(currentCount: 4, maxCount: 6)
            self.speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
        } else {
            self.explosionPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 5)
            self.bombTriggerPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            self.moveSpeedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            self.shieldPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
            self.bombPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 6)
            self.speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
        }
    }
}