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
        
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        self.didSpawn = false
        
        if let entity = self.entity {
            entity.delegate?.entityWillSpawn(entity)
            
            if let visualComponent = entity.componentForClass(VisualComponent),
                let configComponent = entity.componentForClass(ConfigComponent) {
                
                let animRange = configComponent.spawnAnimation.animRangeForDirection(entity.direction)
                visualComponent.spriteNode.texture = visualComponent.sprites[animRange.startIndex]
            }
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
                    
                    let spawnAnim = SKAction.animation(forEntity: entity,
                                                         configuration: configComponent.spawnAnimation,
                                                         state: self)
                    spawnAnim.forEach({ actions.append($0) })
                    
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