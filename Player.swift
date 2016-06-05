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
    
    private let propLoader: PropLoader

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
        
    func dropBomb() -> Bool {
        var didDropBomb = false

        if self.game?.bombCountForPlayer(self.index) < totalBombCount {
            if let game = self.game, let visualComponent = self.componentForClass(VisualComponent) {
                let gridPosition = gridPositionForPosition(visualComponent.spriteNode.position)
                if game.bombAtGridPosition(gridPosition) == nil {
                    do {
                        if let bomb = try self.propLoader.bombWithGridPosition(gridPosition, player: self.index) {
                            bomb.abilityRange = self.abilityRange
                            game.addEntity(bomb)
                            didDropBomb = true
                        }
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            }
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