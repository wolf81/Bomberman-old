//
//  FloatState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/05/16.
//
//

import SpriteKit

class FloatState: State {
    override func updateForEntity(_ entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: @escaping () -> Void) {
        var actions = [SKAction]()
        
        visualComponent.spriteNode.removeAllActions()
        
        let floatAnim = SKAction.animation(forEntity: entity,
                                           configuration: configComponent.floatAnimation,
                                           state: self)
        floatAnim.forEach({ actions.append($0) })
        
        let completion = {
            didUpdate()
            entity.delegate?.entityDidFloat(entity)
        }
        
        if actions.count > 0 {
            visualComponent.spriteNode.run(SKAction.sequence(actions), completion: completion)
        } else {
            completion()
        }
    }
    
    override func defaultAnimation(withDuration duration: TimeInterval, repeatCount: Int) -> SKAction {
        let move = SKAction.moveBy(x: 0, y: CGFloat(unitLength), duration: duration)
        let fade = SKAction.fadeOut(withDuration: duration)
        let anim = SKAction.group([move, fade])
        return anim
    }
}
