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
                                let audioNode = SKAudioNode(URL: NSURL(fileURLWithPath: filePath))
                                audioNode.autoplayLooped = false
                                visualComponent.spriteNode.addChild(audioNode)
                                
                                let play = SKAction.runBlock({
                                    audioNode.runAction(SKAction.play())
                                })
                                
                                actions.append(play)
                            }
                        }
                        
                        if configComponent.hitAnimRange.count > 0 {
                            let texture = visualComponent.sprites[configComponent.hitAnimRange.startIndex]
                            let tileSize = CGSizeMake(CGFloat(unitLength), CGFloat(unitLength))
                            sprite = SKSpriteNode(texture: texture, color: SKColor.whiteColor(), size: tileSize)
                            sprite?.position = visualComponent.spriteNode.position
                            sprite?.zPosition = visualComponent.spriteNode.zPosition + 1
                            
                            entity.game?.gameScene?.world.addChild(sprite!)
                            
                            let hide = SKAction.runBlock({
                                visualComponent.spriteNode.hidden = true
                            })
                            
                            let wait = SKAction.waitForDuration(0.2)
                            
                            let show = SKAction.runBlock({
                                sprite?.removeFromParent()
                                visualComponent.spriteNode.hidden = false
                            })
                            
                            actions.append(SKAction.sequence([hide, wait, show]))
                        }
                    }
                    
                    let completion = {
                        self.updating = false
                        
                        move?.speed = 1
                        
                        if let delegate = entity.delegate {
                            delegate.entityDidHit(entity)
                        }
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