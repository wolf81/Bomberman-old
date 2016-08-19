//
//  AttackState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import SpriteKit
import GameplayKit

class AttackState: State {
    override func updateForEntity(entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: () -> Void) {
        var actions = [SKAction]()
        
        // append sound
        if let attackSound = configComponent.attackSound {
            let filePath = configComponent.configFilePath.stringByAppendingPathComponent(attackSound)
            let play = playAction(forFileAtPath: filePath, spriteNode: visualComponent.spriteNode)
            actions.append(play)
        }
        
        // append animation
        let attackAnimRange = attackAnimRangeForCurrentDirection()
        if attackAnimRange.count > 0 {
            let totalTime: Double = 1.0
            let sprites = Array(visualComponent.sprites[attackAnimRange])
            let timePerFrame = totalTime / Double(sprites.count)
            let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
            actions.append(anim)
        }
        
        let completion = {
            didUpdate()
            entity.delegate?.entityDidAttack(entity)
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
    
    // MARK: - Private
    
    private func attackAnimRangeForCurrentDirection() -> Range<Int> {
        var animRange = 0 ..< 0
        
        if let entity = self.entity, let configComponent = entity.componentForClass(ConfigComponent) {
            animRange = configComponent.attackAnimation.animRangeForDirection(entity.direction)
        }
        
        return animRange
    }
}