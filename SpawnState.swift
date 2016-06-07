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
    private var didSpawn = false
        
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        var isValidNextState: Bool
        
        switch self.entity {
        case is Monster: isValidNextState = (stateClass is RoamState.Type || stateClass is DestroyState.Type)
        case is Projectile: isValidNextState = stateClass is PropelState.Type
        case is Player: isValidNextState = (stateClass is ControlState.Type)
        case is Bomb: isValidNextState = true
        case is Explosion: isValidNextState = (stateClass is DestroyState.Type)
        case is Tile: isValidNextState = (stateClass is DestroyState.Type)
        case is Prop: isValidNextState = (stateClass is DestroyState.Type)
        case is Points: isValidNextState = (stateClass is FloatState.Type)
        case is PowerUp: isValidNextState = true
        default: isValidNextState = false
        }
        
        return isValidNextState
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        self.didSpawn = false
        
        if let entity = self.entity {
            entity.delegate?.entityWillSpawn(entity)
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if !self.didSpawn && !self.updating {
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
                    
                    configComponent.spawnAnimation.duration += entity.spawnTimeAdjustment
                    
                    let anim = SKAction.animation(forEntity: entity, withConfiguration: configComponent.spawnAnimation)
                    actions.appendContentsOf(anim)
                    
//                    let spawnAnim = configComponent.spawnAnimation
//                    if spawnAnim.delay > 0 {
//                        let wait = SKAction.waitForDuration(spawnAnim.delay)
//                        actions.append(wait)
//                    }
//
//                    if spawnAnim.spriteRange.count > 1 {
//                        let timePerFrame = spawnAnim.duration / Double(spawnAnim.spriteRange.count)
//                        let sprites = Array(visualComponent.sprites[spawnAnim.spriteRange])
//                        let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
//                        actions.append(anim)
//                    } else { // fade in?
//                        if visualComponent.sprites.count > 0 {
//                            let sprite = visualComponent.sprites[0]
//                            let update = SKAction.setTexture(sprite)
//                            actions.append(update)
//                        }
//                        
//                        let fadeIn = SKAction.fadeInWithDuration(0.5)
//                        actions.append(fadeIn)
//                    }                    
                    
                    let completion = {
                        self.didSpawn = true
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