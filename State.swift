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
    fileprivate var updating = false
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
    }
    
    var entity: Entity? {
        var entity: Entity?
        
        if let stateMachine = self.stateMachine as! StateMachine? {
            entity = stateMachine.entity
        }
        
        return entity
    }
    
    // MARK: - Private
    
    fileprivate func restartAudioNodeEngineIfNeeded(forAudioNode audioNode: SKAudioNode) {
        if let engine = audioNode.avAudioNode?.engine, engine.isRunning == false {
            engine.prepare()
            
            do {
                try engine.start()
            } catch let error {
                print("\(error)")
            }
        }
    }
    
    // MARK: - Public
    
    override func update(deltaTime seconds: TimeInterval) {
        if !updating && canUpdate() {
            updating = true
            
            if let entity = self.entity,
                let visualComponent = entity.component(ofType: VisualComponent.self),
                let configComponent = entity.component(ofType: ConfigComponent.self) {
                
                var move: SKAction?
                if !canMoveDuringUpdate() {
                    move = visualComponent.spriteNode.action(forKey: "move")
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
    
    func updateForEntity(_ entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: @escaping () -> Void) {
    }
    
    func playAction(forFileAtPath filePath: String, spriteNode: SKSpriteNode) -> SKAction {
        let audioNode = SKAudioNode(url: URL(fileURLWithPath: filePath))
        audioNode.autoplayLooped = false
        
        Game.sharedInstance.gameScene?.addChild(audioNode)
        
        let play = SKAction.run({
            // After switching scenes (e.g. to menu) and returning to the game scene, the audio 
            //  engine apparantly needs a restart - no restart results in a crash.
            self.restartAudioNodeEngineIfNeeded(forAudioNode: audioNode)
            
            audioNode.run(SKAction.play())
        })
    
        return play
    }
    
    func defaultAnimation(withDuration duration: TimeInterval, repeatCount: Int) -> SKAction {
        return SKAction.wait(forDuration: duration)
    }
}
