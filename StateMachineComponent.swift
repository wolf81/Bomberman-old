//
//  StateMachineComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import GameplayKit

class StateMachineComponent: GKComponent {
    let stateMachine: StateMachine
    
    var currentState: State? {
        return self.stateMachine.currentState as! State?
    }
    
    var canRoam: Bool {
        var canRoam = false
        canRoam = self.stateMachine.stateForClass(RoamState) != nil        
        return canRoam
    }
    
    init(game: Game, entity: Entity, states: [State]) {
        self.stateMachine = StateMachine(game: game, entity: entity, states: states)
        
        super.init()
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        self.stateMachine.updateWithDeltaTime(seconds)
    }

    func enterRoamState() {
        self.stateMachine.enterState(RoamState)
    }
    
    func enterAttackState() {
        self.stateMachine.enterState(AttackState)
    }
    
    func enterSpawnState() {
        if (self.stateMachine.currentState is SpawnState) == false {
            if let creature = self.entity as? Creature {
                if let configComponent = creature.componentForClass(ConfigComponent) {
                    creature.health = configComponent.health
                }
            }

            self.stateMachine.enterState(SpawnState)
        }
    }
    
    func enterPropelState() {
        if (self.stateMachine.currentState is PropelState) == false {
            self.stateMachine.enterState(PropelState)
        }
    }
    
    func enterDestroyState() {
        if (self.stateMachine.currentState is DestroyState) == false {
            if let creature = self.entity as? Creature {
                if creature.lives >= 0 {
                    creature.lives -= 1
                }
            }

            self.stateMachine.enterState(DestroyState)
        }
    }
    
    func enterHitState(damage: Int = 1) {
        if (self.stateMachine.currentState is HitState) == false {
            if let creature = self.entity as? Creature {
                creature.health -= damage
            }
            
            self.stateMachine.enterState(HitState)        
        }
    }
    
    func enterControlState() {
        if (self.stateMachine.currentState is ControlState) == false {
            self.stateMachine.enterState(ControlState)
        }
    }
}