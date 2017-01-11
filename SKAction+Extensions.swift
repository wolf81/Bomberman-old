//
//  SKAction+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/05/16.
//
//

import SpriteKit

extension SKAction {
    class func shake(_ initialPosition:CGPoint, duration:Float, amplitudeX:Int = 12, amplitudeY:Int = 3) -> SKAction {
        let startingX = initialPosition.x
        let startingY = initialPosition.y
        let numberOfShakes = duration / 0.015
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let newXPos = startingX + CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let newYPos = startingY + CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            actionsArray.append(SKAction.move(to: CGPoint(x: newXPos, y: newYPos), duration: 0.015))
        }
        actionsArray.append(SKAction.move(to: initialPosition, duration: 0.015))
        return SKAction.sequence(actionsArray)
    }
    
    class func animation(forEntity entity: Entity,
                                   configuration: AnimationConfiguration,
                                   state: State) -> [SKAction] {
        var actions = [SKAction]()
        
        if let visualComponent = entity.component(ofType: VisualComponent.self) {
            if configuration.delay > 0 {
                let wait = SKAction.wait(forDuration: configuration.delay)
                actions.append(wait)
            }
            
            let animRange = configuration.animRangeForDirection(entity.direction)
            
            if animRange.count > 0 {
                let frameCount = animRange.count * configuration.repeatCount
                let timePerFrame = configuration.duration / Double(frameCount)
                
                let sprites = Array(visualComponent.sprites[animRange])
                let anim = SKAction.animate(with: sprites, timePerFrame: timePerFrame)
                
                if configuration.repeatCount > 1 {
                    let repeatAnim = SKAction.repeat(anim, count: configuration.repeatCount)
                    actions.append(repeatAnim)
                } else {
                    actions.append(anim)
                }
            } else {
                let anim = state.defaultAnimation(withDuration: configuration.duration,
                                                  repeatCount: configuration.repeatCount)
                actions.append(anim)
            }
        }
        
        return actions
    }    
}
