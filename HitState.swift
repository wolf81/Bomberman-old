//
//  HitState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 03/05/16.
//
//

import GameplayKit
import SpriteKit

class HitState: State {    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !updating {
            updating = true
            
            var actions = [SKAction]()
            
            if let entity = self.entity,
                let visualComponent = entity.componentForClass(VisualComponent) {
                let move = visualComponent.spriteNode.actionForKey("move")
                move?.speed = 0
                
                if let configComponent = entity.componentForClass(ConfigComponent) {
                    if let hitSound = configComponent.hitSound,
                        let filePath = configComponent.configFilePath?.stringByAppendingPathComponent(hitSound) {
                        let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)
                        actions.append(play)
                    }
                    
                    let hitAnim = configComponent.hitAnimation
                    if hitAnim.delay > 0 {
                        let wait = SKAction.waitForDuration(hitAnim.delay)
                        actions.append(wait)
                    }
                    
                    let animRange = configComponent.hitAnimation.animRangeForDirection(entity.direction)
                    
                    if animRange.count > 0 {
                        let sprites = Array(visualComponent.sprites[animRange])
                        let timePerFrame = hitAnim.duration / Double(animRange.count * hitAnim.repeatCount)
                        let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)                            
                        let wait = SKAction.waitForDuration(hitAnim.duration)
                        
                        if hitAnim.repeatCount > 1 {
                            let repeatAnim = SKAction.repeatAction(anim, count: hitAnim.repeatCount)
                            actions.append(SKAction.group([wait, repeatAnim]))
                        } else {
                            actions.append(SKAction.group([wait, anim]))
                        }
                    }
                    
                    if let lastSprite = visualComponent.spriteNode.texture {
                        let update = SKAction.setTexture(lastSprite)
                        actions.append(update)
                    }
                }
                
                let completion = {
                    // TODO: Does not work correctly when player has a speed boost. Speed boost 
                    //  is removed on hit.
                    move?.speed = 1.0
                    
                    self.updating = false
                    entity.delegate?.entityDidHit(entity)
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