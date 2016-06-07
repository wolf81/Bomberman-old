//
//  CheerState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/05/16.
//
//

import SpriteKit

class CheerState: State {
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating {
            self.updating = true
            
            var actions = [SKAction]()
            
            if let entity = self.entity {
                if let configComponent = entity.componentForClass(ConfigComponent),
                    let visualComponent = entity.componentForClass(VisualComponent) {
                    
                    if let cheerSound = configComponent.cheerSound {
                        if let filePath = configComponent.configFilePath?.stringByAppendingPathComponent(cheerSound) {
                            let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)
                            actions.append(play)
                        }
                    }
                    
                    let move = visualComponent.spriteNode.actionForKey("move")
                    move?.speed = 0
                    
                    let anim = SKAction.animation(forEntity: entity, withConfiguration: configComponent.cheerAnimation)
                    anim.forEach({ actions.append($0) })
                    
                    let completion = {
                        self.updating = false                            
                        entity.delegate?.entityDidCheer(entity)
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