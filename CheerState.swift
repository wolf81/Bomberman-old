//
//  CheerState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/05/16.
//
//

import SpriteKit

class CheerState: State {
    private var didCheer = false
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating && !self.didCheer {
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
                    
                    let cheerAnim = SKAction.animation(forEntity: entity,
                                                       configuration: configComponent.cheerAnimation,
                                                       state: self)
                    cheerAnim.forEach({ actions.append($0) })
                    
                    let completion = {
                        self.updating = false
                        self.didCheer = true
                        
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