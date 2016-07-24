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
            self.actions.remove(.Down)
            self.actions.remove(.Left)
            self.actions.remove(.Up)
            self.actions.remove(.Right)
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
                if action == PlayerAction.Action {
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
                    if action == PlayerAction.Action {
                        continue
                    }
                    
                    direction = movementDirectionForPlayerAction(action)
                    break
                }
                
                if (direction != .None) {
                    player.moveInDirection(direction)
                }
            }
        }
    }
    
    private func movementDirectionForPlayerAction(action: PlayerAction) -> Direction {
        var direction: Direction
        
        switch action {
        case .Up: direction = .Up
        case .Down: direction = .Down
        case .Left: direction = .Left
        case .Right: direction = .Right
        default: direction = .None
        }
        
        return direction
    }
}