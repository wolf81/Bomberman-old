//
//  SKAction+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/05/16.
//
//

import SpriteKit

extension SKAction {
    class func shake(initialPosition:CGPoint, duration:Float, amplitudeX:Int = 12, amplitudeY:Int = 3) -> SKAction {
        let startingX = initialPosition.x
        let startingY = initialPosition.y
        let numberOfShakes = duration / 0.015
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let newXPos = startingX + CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let newYPos = startingY + CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            actionsArray.append(SKAction.moveTo(CGPointMake(newXPos, newYPos), duration: 0.015))
        }
        actionsArray.append(SKAction.moveTo(initialPosition, duration: 0.015))
        return SKAction.sequence(actionsArray)
    }
    
    class func animation(forEntity entity: Entity, withConfiguration configuration: AnimationConfiguration) -> [SKAction] {
        var actions = [SKAction]()
        
        if let visualComponent = entity.componentForClass(VisualComponent) {
            if configuration.delay > 0 {
                let wait = SKAction.waitForDuration(configuration.delay)
                actions.append(wait)
            }
            
            if configuration.spriteRange.count > 0 {
                let frameCount = configuration.spriteRange.count * configuration.repeatCount
                let timePerFrame = configuration.duration / Double(frameCount)
                
                let sprites = Array(visualComponent.sprites[configuration.spriteRange])
                let anim = SKAction.animateWithTextures(sprites, timePerFrame: timePerFrame)
                
                if configuration.repeatCount > 1 {
                    let repeatAnim = SKAction.repeatAction(anim, count: configuration.repeatCount)
                    actions.append(repeatAnim)
                } else {
                    actions.append(anim)
                }
            }
        }

        return actions
    }
}
