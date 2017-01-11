
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
    
    // MARK: - Initialization

    init(game: Game, entity: Entity, states: [State]) {
        self.game = game
        self.entity = entity
        
        super.init(states: states)
    }
    
    // MARK: - Public

    override func update(deltaTime sec: TimeInterval) {
        super.update(deltaTime: sec)
        
        if currentState == nil {
            enter(SpawnState.self)
        }
    }
}
