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
    
    // MARK: - Private
    
    private func restartAudioNodeEngineIfNeeded(forAudioNode audioNode: SKAudioNode) {
        if let engine = audioNode.avAudioNode?.engine where engine.running == false {
            engine.prepare()
            
            do {
                try engine.start()
            } catch let error {
                print("\(error)")
            }
        }
    }
    
    // MARK: - Public
    
    func playAction(forFileAtPath filePath: String, spriteNode: SKSpriteNode) -> SKAction {
        let audioNode = SKAudioNode(URL: NSURL(fileURLWithPath: filePath))
        audioNode.autoplayLooped = false
        
        spriteNode.addChild(audioNode)
        
        let play = SKAction.runBlock({
            // After switching scenes (e.g. to menu) and returning to the game scene, the audio 
            //  engine apparantly needs a restart - no restart results in a crash.
            self.restartAudioNodeEngineIfNeeded(forAudioNode: audioNode)
            
            audioNode.runAction(SKAction.play())
        })
    
        return play
    }
    
    func defaultAnimation(withDuration duration: NSTimeInterval, repeatCount: Int) -> SKAction {
        return SKAction.waitForDuration(duration)
    }
}