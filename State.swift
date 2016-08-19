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
    private var updating = false
    
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
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if !updating && canUpdate() {
            updating = true
            
            if let entity = self.entity,
                let visualComponent = entity.componentForClass(VisualComponent),
                let configComponent = entity.componentForClass(ConfigComponent) {
                
                var move: SKAction?
                if !canMoveDuringUpdate() {
                    move = visualComponent.spriteNode.actionForKey("move")
                    move?.speed = 0
                }
                
                updateForEntity(entity, configComponent: configComponent, visualComponent: visualComponent, didUpdate: {
                    if !self.canMoveDuringUpdate() {
                        move?.speed = 1
                    }
                    
                    self.updating = false
                })
            }
        }
    }
    
    func canUpdate() -> Bool {
        return true
    }
    
    func canMoveDuringUpdate() -> Bool {
        return true
    }
    
    func updateForEntity(entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: () -> Void) {
    }
    
    func playAction(forFileAtPath filePath: String, spriteNode: SKSpriteNode) -> SKAction {
        let audioNode = SKAudioNode(URL: NSURL(fileURLWithPath: filePath))
        audioNode.autoplayLooped = false
        
        Game.sharedInstance.gameScene?.addChild(audioNode)
        
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