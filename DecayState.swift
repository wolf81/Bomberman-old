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
    override func updateForEntity(_ entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: @escaping () -> Void) {
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
            visualComponent.spriteNode.run(SKAction.sequence(actions), completion: completion)
        } else {
            completion()
        }
    }
    
    override func defaultAnimation(withDuration duration: TimeInterval, repeatCount: Int) -> SKAction {
        let timePerFrame = duration / Double(repeatCount * 2)
        
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: timePerFrame)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: timePerFrame)
        let fade = SKAction.sequence([fadeOut, fadeIn])
        let anim = SKAction.repeat(fade, count: repeatCount)
        
        return anim
    }
}
