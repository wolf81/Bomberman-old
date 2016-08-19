//
//  FloatState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/05/16.
//
//

import SpriteKit

class FloatState: State {
    override func updateForEntity(entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent) {
        var actions = [SKAction]()
        
        visualComponent.spriteNode.removeAllActions()
        
        let floatAnim = SKAction.animation(forEntity: entity,
                                           configuration: configComponent.floatAnimation,
                                           state: self)
        floatAnim.forEach({ actions.append($0) })
        
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
    
    override func defaultAnimation(withDuration duration: NSTimeInterval, repeatCount: Int) -> SKAction {
        let move = SKAction.moveByX(0, y: CGFloat(unitLength), duration: duration)
        let fade = SKAction.fadeOutWithDuration(duration)
        let anim = SKAction.group([move, fade])
        return anim
    }
}