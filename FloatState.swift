//
//  FloatState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/05/16.
//
//

import SpriteKit

class FloatState: State {
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating {
            self.updating = true
            
            var actions = [SKAction]()
            
            if let entity = self.entity {
                if let visualComponent = entity.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.removeAllActions()
                    
                    if let configComponent = entity.componentForClass(ConfigComponent) {
                        let totalTime = configComponent.floatDuration
                        let move = SKAction.moveByX(0, y: CGFloat(unitLength), duration: totalTime)
                        let fade = SKAction.fadeOutWithDuration(totalTime)
                        let anim = SKAction.group([move, fade])
                        actions.append(anim)
                    }
                    
                    let completion = {
                        self.updating = false
                        entity.delegate?.entityDidFloat(entity)
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
}