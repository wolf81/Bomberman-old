//
//  SpawnState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/04/16.
//
//

import GameplayKit
import SpriteKit

class SpawnState: State {
    private var destroyDelay: NSTimeInterval?
    private var didShowSpawnAnimation = false
        
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        var isValidNextState: Bool
        
        switch self.entity {
        case is Monster: isValidNextState = (stateClass is RoamState.Type || stateClass is DestroyState.Type)
        case is Projectile: isValidNextState = stateClass is PropelState.Type
        case is Player: isValidNextState = (stateClass is ControlState.Type)
        case is Bomb: isValidNextState = (stateClass is DestroyState.Type)
        case is Explosion: isValidNextState = (stateClass is DestroyState.Type)
        case is Tile: isValidNextState = (stateClass is DestroyState.Type)
        case is Prop: isValidNextState = (stateClass is DestroyState.Type)
        case is Points: isValidNextState = (stateClass is FloatState.Type)
        case is PowerUp: isValidNextState = true
        default: isValidNextState = false
        }
        
        return isValidNextState
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)

        if let configComponent = self.entity?.componentForClass(ConfigComponent) {
            if let destroyDelay = configComponent.destroyDelay {
                self.destroyDelay = destroyDelay
            }
        }
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if self.destroyDelay != nil {
            self.destroyDelay! -= seconds
            
            if self.destroyDelay <= 0 {
                self.entity?.destroy()
            }
        }
        
        if !self.updating {
            self.updating = true
            
            var actions = [SKAction]()

            if let entity = self.entity {
                if let visualComponent = entity.componentForClass(VisualComponent),
                    let configComponent = entity.componentForClass(ConfigComponent) {
                        
                    if let spawnSound = configComponent.spawnSound {
                        if let filePath = configComponent.configFilePath?.stringByAppendingPathComponent(spawnSound) {
                            let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)
                            actions.append(play)
                        }
                    }

                    if configComponent.spawnAnimRange.count > 0 {
                        if configComponent.spawnAnimRange.count > 1 {
                            var totalTime: Double = 1.0
                            
                            if configComponent.destroyDelay > 0 {
                                totalTime = configComponent.destroyDelay!
                            }
                            
                            let sprites = Array(visualComponent.sprites[configComponent.spawnAnimRange])
                            let timePerFrame = totalTime / Double(sprites.count)
                            let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
                            
                            if let _ = entity as? Creature {
                                let fadeIn = SKAction.fadeInWithDuration(totalTime)
                                actions.append(SKAction.group([fadeIn, anim]))
                            } else {
                                actions.append(anim)
                            }
                        } else {
                            let sprite = Array(visualComponent.sprites[configComponent.spawnAnimRange])
                            visualComponent.spriteNode.texture = sprite.first
                            
                            let position = positionForGridPosition(entity.gridPosition)
                            visualComponent.spriteNode.position = position
                            
                            let fadeIn = SKAction.fadeInWithDuration(0.5)
                            actions.append(fadeIn)
                        }
                    }
                
                    let completion = {
                        self.updating = false
                        entity.delegate?.entityDidSpawn(entity)
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