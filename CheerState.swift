//
//  CheerState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/05/16.
//
//

import SpriteKit

class CheerState: State {
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return !(stateClass is CheerState.Type)
    }
    
    override func updateForEntity(entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: () -> Void) {
        var actions = [SKAction]()
        
        if let cheerSound = configComponent.cheerSound {
            let filePath = configComponent.configFilePath.stringByAppendingPathComponent(cheerSound)
            let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)
            actions.append(play)
        }
        
        let cheerAnim = SKAction.animation(forEntity: entity,
                                           configuration: configComponent.cheerAnimation,
                                           state: self)
        cheerAnim.forEach({ actions.append($0) })
        
        let completion = {
            didUpdate()
            
            entity.delegate?.entityDidCheer(entity)
        }
        
        if actions.count > 0 {
            visualComponent.spriteNode.runAction(SKAction.sequence(actions), completion: completion)
        } else {
            completion()
        }
    }
    
    override func canMoveDuringUpdate() -> Bool {
        return false
    }
}