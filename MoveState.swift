//
//  MoveState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/08/16.
//
//

import SpriteKit

class MoveState : State {
    fileprivate var isMoving = false
    
    override func update(deltaTime seconds: TimeInterval) {
        // check if other monster at next grid position. If yes: stop move.
        
        guard
            let creature = self.entity as? Creature,
            let configComponent = creature.component(ofType: ConfigComponent.self),
            let visualComponent = creature.component(ofType: VisualComponent.self), creature.direction != .none else {
            return
        }
        
        if visualComponent.spriteNode.hasActions() == false {
            isMoving = false
        }
        
        if isMoving {
            return
        }
        
        isMoving = true
        
        var actions = [SKAction]()
        
        let position = visualComponent.spriteNode.position
        var toPosition = CGPoint(x: position.x, y: position.y)
        var gridPosition: Point = creature.gridPosition
        
        let xOffset = Int(ceil(position.x)) % unitLength
        _ = unitLength / 2 + Int(ceil(position.y)) % unitLength
        print("xOffset: \(xOffset)")
        
        switch creature.direction {
        case .up:
            toPosition.y += CGFloat(unitLength)
            gridPosition.y += 1
        case .down:
            toPosition.y -= CGFloat(unitLength)
            gridPosition.y -= 1
        case .left:
            toPosition.x -= CGFloat(unitLength)
            gridPosition.x -= 1
        case .right:
            toPosition.x += CGFloat(unitLength)
            gridPosition.x += 1
        case .none: break
        }
        
        let testPos = positionForGridPosition(gridPosition)
        let dX = position.x - testPos.x
        print("dX: \(dX)")

        
        if creature.direction != .none {
            let duration: TimeInterval = 1.0 // = dX == 0 ? 1.0 : 72 / Double(fabs(dX))
            let move = SKAction.move(to: toPosition, duration: duration)
            
            let animRange = configComponent.moveAnimation.animRangeForDirection(creature.direction)
            if animRange.upperBound > 0 {
                let textures = Array(visualComponent.sprites[animRange])
                let timePerFrame = duration / Double(textures.count)
                let animate = SKAction.animate(with: textures, timePerFrame: timePerFrame)
                actions.append(SKAction.group([move, animate]))
            } else {
                actions.append(move)
            }
        } else {
            print("no direction set for: \(creature.name)")
        }
        
        let completion = {
            creature.gridPosition = gridPositionForPosition(toPosition)
            creature.direction = .none
            self.isMoving = false
        }
        
        if actions.count > 0 {
            visualComponent.spriteNode.run(SKAction.sequence(actions), completion: completion)
        }
    }
}
