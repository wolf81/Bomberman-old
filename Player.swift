//
//  Player.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/05/16.
//
//

import Foundation

class Player: Creature {
    let index: PlayerIndex
    
    private let propLoader: PropLoader
    
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

        self.abilityRange = 2

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
    
    func addExplosionPower() {
        if self.explosionPowerLimit.currentCount < self.explosionPowerLimit.maxCount {
            self.explosionPowerLimit.currentCount += 1
        }
    }
    
    func addShieldPower() {
        if self.shieldPowerLimit.currentCount < self.shieldPowerLimit.maxCount {
            self.shieldPowerLimit.currentCount += 1
        }
    }
    
    func dropBomb() throws -> Bool {
        var didDropBomb = false

        if self.game?.bombCountForPlayer(self.index) < self.bombPowerLimit.currentCount  {
            if let game = self.game, let visualComponent = self.componentForClass(VisualComponent) {
                let gridPosition = gridPositionForPosition(visualComponent.spriteNode.position)
                if game.bombAtGridPosition(gridPosition) == nil {
                    if let bomb = try self.propLoader.bombWithGridPosition(gridPosition, player: self.index) {
                        bomb.abilityRange = self.explosionPowerLimit.currentCount
                        game.addEntity(bomb)
                        didDropBomb = true
                    }
                }
            }
        }
        
        return didDropBomb
    }
    
    override func spawn() {
        self.resetPowerUps()
        
        super.spawn()
    }
    
    override func hit() {
        if self.shieldPowerLimit.currentCount == 0 {
            super.hit()
        }
    }
    
    override func destroy() {
        if self.shieldPowerLimit.currentCount == 0 {
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
    
    // MARK: - Private
    
    private func resetPowerUps() {
        self.explosionPowerLimit = PowerUpLimit(currentCount: 2, maxCount: 5)
        self.bombTriggerPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
        self.shieldPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
        self.bombPowerLimit = PowerUpLimit(currentCount: 4, maxCount: 6)
        self.speedPowerLimit = PowerUpLimit(currentCount: 0, maxCount: 1)
    }
}