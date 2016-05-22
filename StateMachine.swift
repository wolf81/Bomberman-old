
//
//  StateMachine.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit

class StateMachine: GKStateMachine {
    weak var entity: Entity?
    weak var game: Game?
        
    init(game: Game, entity: Entity, states: [State]) {
        self.game = game
        self.entity = entity
        
        super.init(states: states)
    }
    
    override func updateWithDeltaTime(sec: NSTimeInterval) {
        super.updateWithDeltaTime(sec)
        
        if self.currentState == nil {
            enterState(SpawnState)
        }
    }
}