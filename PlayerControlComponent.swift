//
//  PlayerControlComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit

class PlayerControlComponent: GKComponent {
    weak var player: Creature?
    
    private var actions = [PlayerAction]()
    
    init (player: Creature) {
        super.init()

        self.player = player
    }
    
    func remove(action: PlayerAction) {
        if let index = actions.indexOf(action) {
            actions.removeAtIndex(index)
        }
    }
    
    func removeAllActions() {
        actions.removeAll()
    }
    
    func insert(action: PlayerAction) {
        if let index = actions.indexOf(action) {
            actions.removeAtIndex(index)
        }
        
        actions.insert(action, atIndex: 0)
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if let action = self.actions.first {
            if let player = self.player {
                if player.isControllable {
                    switch action {
                    case .DropBomb:
                        player.dropBomb()
                        remove(action)
                    default:
                        if player.isMoving == false {
                            let direction = movementDirectionForPlayerAction(action)
                            if player.moveInDirection(direction) == false {
                                remove(action)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func movementDirectionForPlayerAction(action: PlayerAction) -> Direction {
        var direction: Direction
        
        switch action {
        case .MoveUp: direction = .North
        case .MoveDown: direction = .South
        case .MoveLeft: direction = .West
        case .MoveRight: direction = .East
        default: direction = .None
        }
        
        return direction
    }
}