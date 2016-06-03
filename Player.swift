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
    
    private var totalBombCount: Int = 4
    private var currentBombCount: Int = 4
    private var bombRefillTime: NSTimeInterval = 2.0

    init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point, playerIndex: PlayerIndex) {
        self.index = playerIndex
        
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
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if self.currentBombCount < self.totalBombCount {
            if self.bombRefillTime > 0 {
                self.bombRefillTime -= seconds
            } else {
                self.currentBombCount += 1
                self.bombRefillTime = self.abilityCooldown
            }
        } else {
            self.bombRefillTime = self.abilityCooldown
        }
    }
    
    func dropBomb() -> Bool {
        var didDropBomb = false
        
        if self.currentBombCount > 0 {
            if let game = self.game {
                let propLoader = PropLoader(forGame: game)
                if let position = self.componentForClass(VisualComponent)?.spriteNode.position {
                    let gridPosition = gridPositionForPosition(position)
                    
                    if game.bombAtGridPosition(gridPosition) == nil {
                        do {
                            if let bomb = try propLoader.bombWithGridPosition(gridPosition) {
                                game.addEntity(bomb)
                                
                                didDropBomb = true
                                
                            }
                        } catch let error {
                            print("error: \(error)")
                        }
                    }
                }
            }
        }
        
        if didDropBomb {
            self.currentBombCount -= 1
        }
        
        return didDropBomb
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
}