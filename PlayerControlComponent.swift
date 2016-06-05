//
//  PlayerControlComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit

class PlayerControlComponent: GKComponent {
    weak var player: Player?
    
    private var actions = Set<PlayerAction>()
    
    init (player: Player) {
        super.init()

        self.player = player
    }
    
    func addAction(action: PlayerAction) {
        if action == PlayerAction.None {
            self.actions.remove(.MoveDown)
            self.actions.remove(.MoveLeft)
            self.actions.remove(.MoveUp)
            self.actions.remove(.MoveRight)
        } else {
            self.actions.insert(action)
        }
    }
    
    func removeAction(action: PlayerAction) {
        self.actions.remove(action)
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if let player = self.player where player.isControllable {
            for action in actions {
                if action == PlayerAction.DropBomb {
                    do {
                        try player.dropBomb()
                    } catch let error {
                        print("error: \(error)")
                    }
                    
                    removeAction(action)
                }
            }
            
            if !player.isMoving {
                var direction = Direction.None
                
                for action in actions {
                    if action == PlayerAction.DropBomb {
                        continue
                    }
                    
                    direction = movementDirectionForPlayerAction(action)
                    break
                }
                
                player.moveInDirection(direction)
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