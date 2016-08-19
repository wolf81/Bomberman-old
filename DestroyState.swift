//
//  DestroyState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/04/16.
//
//

import GameplayKit
import SpriteKit

class DestroyState: State {
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return (stateClass is SpawnState.Type)
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        if let entity = self.entity {
            entity.delegate?.entityWillDestroy(entity)
        }
    }
    
    override func updateForEntity(entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent) {
        var actions = [SKAction]()
        
        visualComponent.spriteNode.removeAllActions()
        
        if let destroySound = configComponent.destroySound {
            let filePath = configComponent.configFilePath.stringByAppendingPathComponent(destroySound)
            let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)
            actions.append(play)
        }
        
        let destroyAnim = SKAction.animation(forEntity: entity,
                                             configuration: configComponent.destroyAnimation,
                                             state: self)
        destroyAnim.forEach({ actions.append($0) })
        
//        let fadeOut = SKAction.fadeOutWithDuration(0.5)
//        actions.append(fadeOut)
        
        let completion = {
            self.updating = false
            entity.delegate?.entityDidDestroy(entity)
        }
        
        if actions.count > 0 {
            visualComponent.spriteNode.runAction(SKAction.sequence(actions), completion: completion)
        } else {
            completion()
        }
    }
}
