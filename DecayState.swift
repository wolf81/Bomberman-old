//
//  DisintegrateState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/06/16.
//
//

import GameplayKit
import SpriteKit

class DecayState : State {
    override func updateForEntity(entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: () -> Void) {
        var actions = [SKAction]()
        
        let decayAnim = SKAction.animation(forEntity: entity,
                                           configuration: configComponent.decayAnimation,
                                           state: self)
        decayAnim.forEach({ actions.append($0) })
        
        let completion = {
            didUpdate()
            entity.delegate?.entityDidDecay(entity)
        }
        
        if actions.count > 0 {
            visualComponent.spriteNode.runAction(SKAction.sequence(actions), completion: completion)
        } else {
            completion()
        }
    }
    
    override func defaultAnimation(withDuration duration: NSTimeInterval, repeatCount: Int) -> SKAction {
        let timePerFrame = duration / Double(repeatCount * 2)
        
        let fadeOut = SKAction.fadeAlphaTo(0.5, duration: timePerFrame)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: timePerFrame)
        let fade = SKAction.sequence([fadeOut, fadeIn])
        let anim = SKAction.repeatAction(fade, count: repeatCount)
        
        return anim
    }
}