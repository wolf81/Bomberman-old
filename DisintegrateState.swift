//
//  DisintegrateState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/06/16.
//
//

import GameplayKit
import SpriteKit

class DisintegrateState : State {
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is DestroyState.Type
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating {
            self.updating = true
            
            var actions = [SKAction]()
            
            if let entity = self.entity {
                if let configComponent = entity.componentForClass(ConfigComponent),
                    let visualComponent = entity.componentForClass(VisualComponent) {
                    
                    let anim = SKAction.animation(forEntity: entity, withConfiguration: configComponent.disintegrateAnimation)
                    anim.forEach({ actions.append($0) })
                    
                    let completion = {
                        self.updating = false
                        entity.delegate?.entityDidDisintegrate(entity)
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