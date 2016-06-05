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
    private(set) var bombPowerLimit = PowerUpLimit(currentCount: 4, maxCount: 6)
    private(set) var speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    
    // MARK: - Initialization
    
    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, playerIndex: PlayerIndex) {
        self.index = playerIndex
        self.propLoader = PropLoader(forGame: game)
        
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)

        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = 90
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = playerCategory
                physicsBody.contactTestBitMask = playerCategory
                physicsBody.collisionBitMask = nothingCategory
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
    }
    
    func addExplosionPower() {
        if self.explosionPowerLimit.currentCount < self.explosionPowerLimit.maxCount {
            self.explosionPowerLimit.currentCount += 1
        }
    }
    
    func addShieldPower(withDuration duration: NSTimeInterval) {
        if self.shieldPowerLimit.currentCount < self.shieldPowerLimit.maxCount {
            self.shieldPowerLimit.currentCount += 1
            self.shieldDuration = duration
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
        
        self.addShieldPower(withDuration: 2.0)
        updateForShield()
        
        super.spawn()
    }
    
    override func hit() {
        if self.shieldPowerLimit.currentCount == 0 {
            super.hit()
        }
    }
    
    override func destroy() {
        if self.shieldPowerLimit.currentCount == 0 && !self.isDestroyed {
            self.resetPowerUps()

            self.health = 0
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
    
    func updateForShield() {
        // TODO: Clean-up the code for getting shield texture. Should be more dynamic,
        //  like entities. Perhaps the shield can be parsed as prop.
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.removeAllChildren()
            
            if self.shieldPowerLimit.currentCount > 0 {
                let shieldTexture = SKTexture(imageNamed: "Shield.png")
                let spriteSize = CGSizeMake(32, 32)
                let shieldSprites = SpriteLoader.spritesFromTexture(shieldTexture, withSpriteSize: spriteSize)
                
                var shieldSprite: SKTexture
                
                switch self.direction {
                case .West: shieldSprite = shieldSprites[2]
                case .East: shieldSprite = shieldSprites[1]
                default: shieldSprite = shieldSprites[0]
                }
                
                let shieldNode = SKSpriteNode(texture: shieldSprite, size: visualComponent.spriteNode.size)
                shieldNode.alpha = 0.5
                shieldNode.zPosition = 1000
                visualComponent.spriteNode.addChild(shieldNode)
            }
        }
    }
    
    // MARK: - Private
    
    private func resetPowerUps() {
        self.explosionPowerLimit = PowerUpLimit(currentCount: 2, maxCount: 5)
        self.bombTriggerPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
        self.shieldPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
        self.bombPowerLimit = PowerUpLimit(currentCount: 4, maxCount: 6)
        self.speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    }
}