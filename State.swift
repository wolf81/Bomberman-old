//
//  State.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 30/04/16.
//
//

import SpriteKit
import GameplayKit

class State: GKState {
    var updating = false

    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
    }
    
    var entity: Entity? {
        var entity: Entity?
        
        if let stateMachine = self.stateMachine as! StateMachine? {
            entity = stateMachine.entity
        }
        
        return entity
    }
    
    // MARK - Public
    
    func playAction(forFileAtPath filePath: String, spriteNode: SKSpriteNode) -> SKAction {
        let audioNode = SKAudioNode(URL: NSURL(fileURLWithPath: filePath))
        audioNode.autoplayLooped = false
        
        spriteNode.addChild(audioNode)
        
        let play = SKAction.runBlock({
            audioNode.runAction(SKAction.play())
        })
    
        return play
    }
}