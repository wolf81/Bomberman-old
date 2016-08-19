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
    override func updateForEntity(entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: () -> Void) {
        var actions = [SKAction]()
        
        if let hitSound = configComponent.hitSound {
            let filePath = configComponent.configFilePath.stringByAppendingPathComponent(hitSound)
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
        
        let completion = {
            // TODO: Does not work correctly when player has a speed boost. Speed boost
            //  is removed on hit.
            didUpdate()
            entity.delegate?.entityDidHit(entity)
        }
        
        if actions.count > 0 {
            visualComponent.spriteNode.runAction(SKAction.sequence(actions), completion: completion)
        } else {
            completion()
        }
    }
    
    override func canMoveDuringUpdate() -> Bool {
        return false
    }
}