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
                        if configComponent.destroyAnimRange.count > 0 {
                            let totalTime = configComponent.destroyDuration
                            let sprites = Array(visualComponent.sprites[configComponent.destroyAnimRange])
                            let timePerFrame = totalTime / Double(sprites.count)
                            let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
                            actions.append(anim)
                            
                            if let creature = entity as? Creature {
                                if creature.lives < 0 {
                                    let fade = SKAction.fadeOutWithDuration(0.2)
                                    actions.append(fade)
                                }
                            } else {
                                let fade = SKAction.fadeOutWithDuration(0.2)
                                actions.append(fade)
                            }
                        }
                        
                        if let value = entity.value {
                            let propLoader = PropLoader(forGame: Game.sharedInstance)
                            let points = (try! propLoader.pointsWithType(value, gridPosition: entity.gridPosition))!
                            Game.sharedInstance.addEntity(points)
                        }
                    }
                    
                    let completion = {
                        self.updating = false
                        
                        if let delegate = entity.delegate {
                            delegate.entityDidDestroy(entity)
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
