//
//  PropelState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 05/05/16.
//
//

import GameplayKit

class PropelState: State {
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating {
            self.updating = true
            
            if let entity = self.entity as? Projectile {
                if let visualComponent = entity.componentForClass(VisualComponent) {
                    let direction = entity.direction
                    var gridPosition = entity.gridPosition
                    
                    switch entity.direction {
                    case .North: gridPosition.y += 1
                    case .South: gridPosition.y -= 1
                    case .West: gridPosition.x -= 1
                    case .East: gridPosition.x += 1
                    default: break
                    }
                    
                    if let toPosition = entity.game?.positionForGridPosition(gridPosition) {
                        visualComponent.moveInDirection(direction, toPosition: toPosition, completion: {
                            entity.gridPosition = gridPosition
                            self.updating = false
                        })
                    }
                }
            }
        }
    }
}