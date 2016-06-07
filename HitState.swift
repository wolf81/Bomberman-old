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
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return (stateClass is DestroyState.Type) || (stateClass is ControlState.Type)
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)            
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !self.updating {
            self.updating = true
            
            var actions = [SKAction]()
            
            if let entity = self.entity {
                if let visualComponent = entity.componentForClass(VisualComponent) {
                    let move = visualComponent.spriteNode.actionForKey("move")
                    move?.speed = 0
                    
                    var sprite: SKSpriteNode? = visualComponent.spriteNode
                    
                    if let configComponent = entity.componentForClass(ConfigComponent) {
                        if let hitSound = configComponent.hitSound {
                            if let filePath = configComponent.configFilePath?.stringByAppendingPathComponent(hitSound) {
                                let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)
                                actions.append(play)
                            }
                        }
                        
                        let hitAnim = configComponent.hitAnimation
                        if hitAnim.delay > 0 {
                            let wait = SKAction.waitForDuration(hitAnim.delay)
                            actions.append(wait)
                        }
                        
                        if hitAnim.spriteRange.count > 0 {
                            let sprites = Array(visualComponent.sprites[hitAnim.spriteRange])
                            let size = visualComponent.spriteNode.size
                            sprite = SKSpriteNode(texture: sprites.first, color: SKColor.whiteColor(), size: size)
                            sprite?.position = visualComponent.spriteNode.position
                            sprite?.zPosition = visualComponent.spriteNode.zPosition + 1
                            
                            entity.game?.gameScene?.world.addChild(sprite!)
                            
                            let hide = SKAction.runBlock({
                                visualComponent.spriteNode.hidden = true
                            })
                            
                            let timePerFrame = hitAnim.duration / Double(hitAnim.spriteRange.count * hitAnim.repeatCount)
                            let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
                            
                            if hitAnim.repeatCount > 1 {
                                let repeatAnim = SKAction.repeatAction(anim, count: hitAnim.repeatCount)
                                sprite?.runAction(repeatAnim)
                            } else {
                                sprite?.runAction(anim)
                            }
                            
                            let wait = SKAction.waitForDuration(hitAnim.duration)
                            
                            let show = SKAction.runBlock({
                                sprite?.removeFromParent()
                                visualComponent.spriteNode.hidden = false
                            })
                            
                            actions.append(SKAction.sequence([hide, wait, show]))
                        }
                    }
                    
                    let completion = {
                        move?.speed = 1

                        self.updating = false
                        entity.delegate?.entityDidHit(entity)
                    }
                    
                    if actions.count > 0 {
                        sprite?.runAction(SKAction.sequence(actions), completion: completion)
                    } else {
                        completion()
                    }
                }
            }
        }
    }
}