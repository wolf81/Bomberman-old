//
//  MoveState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/08/16.
//
//

import SpriteKit

class MoveState : State {
    private var isMoving = false
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        // check if other monster at next grid position. If yes: stop move.
        
        guard
            let creature = self.entity as? Creature,
            let configComponent = creature.componentForClass(ConfigComponent),
            let visualComponent = creature.componentForClass(VisualComponent)
            where creature.direction != .None else {
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
        var toPosition = CGPointMake(position.x, position.y)
        var gridPosition: Point = creature.gridPosition
        
        let xOffset = Int(ceil(position.x)) % unitLength
        let yOffset = unitLength / 2 + Int(ceil(position.y)) % unitLength
        print("xOffset: \(xOffset)")
        
        switch creature.direction {
        case .Up:
            toPosition.y += CGFloat(unitLength)
            gridPosition.y += 1
        case .Down:
            toPosition.y -= CGFloat(unitLength)
            gridPosition.y -= 1
        case .Left:
            toPosition.x -= CGFloat(unitLength)
            gridPosition.x -= 1
        case .Right:
            toPosition.x += CGFloat(unitLength)
            gridPosition.x += 1
        case .None: break
        }
        
        let testPos = positionForGridPosition(gridPosition)
        let dX = position.x - testPos.x
        print("dX: \(dX)")

        
        if creature.direction != .None {
            let duration: NSTimeInterval = 1.0 // = dX == 0 ? 1.0 : 72 / Double(fabs(dX))
            let move = SKAction.moveTo(toPosition, duration: duration)
            
            let animRange = configComponent.moveAnimation.animRangeForDirection(creature.direction)
            if animRange.endIndex > 0 {
                let textures = Array(visualComponent.sprites[animRange])
                let timePerFrame = duration / Double(textures.count)
                let animate = SKAction.animateWithTextures(textures, timePerFrame: timePerFrame)
                actions.append(SKAction.group([move, animate]))
            } else {
                actions.append(move)
            }
        } else {
            print("no direction set for: \(creature.name)")
        }
        
        let completion = {
            creature.gridPosition = gridPositionForPosition(toPosition)
            creature.direction = .None
            self.isMoving = false
        }
        
        if actions.count > 0 {
            visualComponent.spriteNode.runAction(SKAction.sequence(actions), completion: completion)
        }
    }
}