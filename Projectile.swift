//
//  Projectile.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import Foundation

class Projectile: Entity {
    var direction = Direction.None
    
    override init(forGame game: Game, configComponent: ConfigComponent, gridPosition: Point) {
        super.init(forGame: game, configComponent: configComponent, gridPosition: gridPosition)
        
        if let visualComponent = componentForClass(VisualComponent) {
            visualComponent.spriteNode.zPosition = 100
            
            if let physicsBody = visualComponent.spriteNode.physicsBody {
                physicsBody.categoryBitMask = projectileCategory
                physicsBody.contactTestBitMask = playerCategory | tileCategory
                physicsBody.collisionBitMask = 0
            }
        }
    }
    
    func moveForwards() {
        if let visualComponent = componentForClass(VisualComponent) {
            var gridPosition = self.gridPosition
            
            switch direction {
            case .North: gridPosition.y += 1
            case .South: gridPosition.y -= 1
            case .West: gridPosition.x -= 1
            case .East: gridPosition.x += 1
            default: break
            }
            
            if let toPosition = self.game?.positionForGridPosition(gridPosition) {
                visualComponent.moveInDirection(self.direction, toPosition: toPosition, completion: {
                    self.gridPosition = gridPosition
                    self.moveForwards()
                })
            }
        }
    }
}