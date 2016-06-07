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
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating {
            self.updating = true
            
            var actions = [SKAction]()
            
            if let entity = self.entity {
                if let visualComponent = entity.componentForClass(VisualComponent) {
                    visualComponent.spriteNode.removeAllActions()

                    if let creature = entity as? Creature {
                        // Creatures that are destroyed should no longer collide with projectiles,
                        //  bombs, etc..
                        if creature.lives < 0 {
                            visualComponent.spriteNode.physicsBody = nil
                        }
                    } else {
                        visualComponent.spriteNode.physicsBody = nil
                    }
                    
                    if let configComponent = entity.componentForClass(ConfigComponent) {
                        if let destroySound = configComponent.destroySound {
                            if let filePath = configComponent.configFilePath?.stringByAppendingPathComponent(destroySound) {
                                let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)                                
                                actions.append(play)
                            }
                        }

                        if let destroyAnim = configComponent.destroyAnimation {
                            if destroyAnim.delay > 0 {
                                let wait = SKAction.waitForDuration(destroyAnim.delay)
                                actions.append(wait)
                            }
                            
                            if destroyAnim.spriteRange.count > 1 {
                                let timePerFrame = destroyAnim.duration / Double(destroyAnim.spriteRange.count * destroyAnim.repeatCount)
                                let sprites = Array(visualComponent.sprites[destroyAnim.spriteRange])
                                let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
                                
                                if destroyAnim.repeatCount > 1 {
                                    let repeatAnim = SKAction.repeatAction(anim, count: destroyAnim.repeatCount)
                                    actions.append(repeatAnim)
                                } else {
                                    actions.append(anim)
                                }
                            }
                            
                            let fadeOut = SKAction.fadeOutWithDuration(0.5)
                            actions.append(fadeOut)
                        } else {
                            if configComponent.destroyAnimRange.count > 0 {
                                let totalTime = configComponent.destroyDuration
                                let sprites = Array(visualComponent.sprites[configComponent.destroyAnimRange])
                                let animRepeat = configComponent.destroyAnimRepeat
                                
                                let timePerFrame = totalTime / Double(sprites.count * animRepeat)
                                let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
                                
                                if animRepeat > 1 {
                                    let repeatAction = SKAction.repeatAction(anim, count: animRepeat)
                                    actions.append(repeatAction)
                                } else {
                                    actions.append(anim)
                                }
                                
                                let fade = SKAction.fadeOutWithDuration(0.5)
                                actions.append(fade)
                            }
                        }                        
                    }
                    
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
        }
    }
}
