//
//  CheerState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/05/16.
//
//

import SpriteKit

class CheerState: State {
//    override func isValidNextState(stateClass: AnyClass) -> Bool {
//        return false
//    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating {
            self.updating = true
            
            var actions = [SKAction]()
            
            if let entity = self.entity {
                if let configComponent = entity.componentForClass(ConfigComponent) {
                    if let visualComponent = entity.componentForClass(VisualComponent) {
                        if let cheerSound = configComponent.cheerSound {
                            if let filePath = configComponent.configFilePath?.stringByAppendingPathComponent(cheerSound) {
                                let audioNode = SKAudioNode(URL: NSURL(fileURLWithPath: filePath))
                                audioNode.autoplayLooped = false
                                visualComponent.spriteNode.addChild(audioNode)
                                                                
                                let play = SKAction.runBlock({
                                    audioNode.runAction(SKAction.play())
                                })
                                
                                actions.append(play)
                            }
                        }
                        
                        let move = visualComponent.spriteNode.actionForKey("move")
                        move?.speed = 0
                        
                        let animRange = configComponent.cheerAnimRange
                        if animRange.count > 0 {
                            let totalTime = configComponent.cheerDuration
                            let sprites = Array(visualComponent.sprites[animRange])
                            let timePerFrame = totalTime / Double(sprites.count)
                            let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
                            actions.append(anim)
                        }
                        
                        let completion = {
                            self.updating = false
                            
                            if let delegate = entity.delegate {
                                delegate.entityDidCheer(entity)
                            }
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
}