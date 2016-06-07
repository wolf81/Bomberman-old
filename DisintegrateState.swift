//
//  DisintegrateState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/06/16.
//
//

import GameplayKit
import SpriteKit

class DisintegrateState : State {
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return (stateClass is DestroyState.Type)
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
                    
                    if let configComponent = entity.componentForClass(ConfigComponent) {
//                        spawnDelay = configComponent.spawnDelay
//                        
//                        if let destroySound = configComponent.destroySound {
//                            if let filePath = configComponent.configFilePath?.stringByAppendingPathComponent(destroySound) {
//                                let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)
//                                actions.append(play)
//                            }
//                        }
//                        
//                        if configComponent.destroyAnimRange.count > 0 {
//                            let totalTime = configComponent.destroyDuration
//                            let sprites = Array(visualComponent.sprites[configComponent.destroyAnimRange])
//                            let animRepeat = configComponent.destroyAnimRepeat
//                            
//                            let timePerFrame = totalTime / Double(sprites.count * animRepeat)
//                            let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
//                            
//                            if animRepeat > 1 {
//                                let repeatAction = SKAction.repeatAction(anim, count: animRepeat)
//                                actions.append(repeatAction)
//                            } else {
//                                actions.append(anim)
//                            }
//                            
//                            let fade = SKAction.fadeOutWithDuration(0.5)
//                            actions.append(fade)
//                        }
//                        
//                        if let value = entity.value {
//                            let propLoader = PropLoader(forGame: Game.sharedInstance)
//                            let points = (try! propLoader.pointsWithType(value, gridPosition: entity.gridPosition))!
//                            Game.sharedInstance.addEntity(points)
//                        }
                    }
                    
                    let completion = {
//                        delay(spawnDelay, closure: {
//                            self.updating = false
//                            
//                            entity.delegate?.entityDidDestroy(entity)
//                        })
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