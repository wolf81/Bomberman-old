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
    
    fileprivate var actions = Set<PlayerAction>()
    
    init (player: Player) {
        super.init()

        self.player = player
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAction(_ action: PlayerAction) {
        if action == PlayerAction.none {
            self.actions.remove(.down)
            self.actions.remove(.left)
            self.actions.remove(.up)
            self.actions.remove(.right)
        } else {
            self.actions.insert(action)
        }
    }
    
    func removeAction(_ action: PlayerAction) {
        self.actions.remove(action)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if let player = self.player, player.isControllable {
            for action in actions {
                if action == PlayerAction.action {
                    do {
                        _ = try player.dropBomb()
                    } catch let error {
                        print("error: \(error)")
                    }
                    
                    removeAction(action)
                }
            }
            
            if !player.isMoving {
                var direction = Direction.none
                
                for action in actions {
                    if action == PlayerAction.action {
                        continue
                    }
                    
                    direction = movementDirectionForPlayerAction(action)
                    break
                }
                
                if (direction != .none) {
                    _ = player.moveInDirection(direction)
                }
            }
        }
    }
    
    fileprivate func movementDirectionForPlayerAction(_ action: PlayerAction) -> Direction {
        var direction: Direction
        
        switch action {
        case .up: direction = .up
        case .down: direction = .down
        case .left: direction = .left
        case .right: direction = .right
        default: direction = .none
        }
        
        return direction
    }
}
