//
//  AttackState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import SpriteKit

class AttackState: State {
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating {
            print("self.entity: \(self.entity)")
            
            self.updating = true
            
            var actions = [SKAction]()
            
            if let entity = self.entity {
                if let visualComponent = entity.componentForClass(VisualComponent) {
                    let move = visualComponent.spriteNode.actionForKey("move")
                    move?.speed = 0

                    let attackAnimRange = attackAnimRangeForCurrentDirection()
                    if attackAnimRange.count > 0 {
                        let totalTime: Double = 1.0
                        let sprites = Array(visualComponent.sprites[attackAnimRange])
                        let timePerFrame = totalTime / Double(sprites.count)
                        let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
                        actions.append(anim)
                    }
                    
                    let completion = {
                        self.updating = false
                        
                        if let delegate = entity.delegate {
                            move?.speed = 1
                            delegate.entityDidAttack(entity)
                        }
                    }
                    
                    if actions.count > 0 {
                        visualComponent.spriteNode.runAction(SKAction.sequence(actions), completion: completion)
                    } else {
                        completion()
                    }
                }
            }
        }
    }
    
    private func attackAnimRangeForCurrentDirection() -> Range<Int> {
        var animRange = 0 ..< 0
        
        if let entity = self.entity {
            if let configComponent = entity.componentForClass(ConfigComponent) {
                let creature = entity as! Creature
                switch creature.direction {
                case .North: animRange = configComponent.attackUpAnimRange
                case .West: animRange = configComponent.attackLeftAnimRange
                case .South: animRange = configComponent.attackDownAnimRange
                case .East: animRange = configComponent.attackRightAnimRange
                case .None: break
                }
            }
        }
        
        return animRange
    }
}