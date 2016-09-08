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
        canRoam = self.stateMachine.stateForClass(MoveState) != nil
        return canRoam
    }

    var canAttack: Bool {
        var canAttack = false
        canAttack = self.stateMachine.stateForClass(AttackState) != nil
        return canAttack
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
        self.stateMachine.enterState(MoveState)
    }
    
    func enterAttackState() {
        self.stateMachine.enterState(AttackState)
    }
    
    func enterSpawnState() {
        if (self.stateMachine.currentState is SpawnState) == false {
            if let creature = self.entity as? Creature where creature.lives >= 0 {
                if let configComponent = creature.componentForClass(ConfigComponent) {
                    creature.health = configComponent.health
                }
            }

            self.stateMachine.enterState(SpawnState)
        }
    }
        
    func enterCheerState() {
        if (self.stateMachine.currentState is CheerState) == false {
            self.stateMachine.enterState(CheerState)
        }
    }
    
    func enterFloatState() {
        if (self.stateMachine.currentState is FloatState) == false {
            self.stateMachine.enterState(FloatState)
        }
    }

    func enterDecayState() {
        if (self.stateMachine.currentState is DecayState) == false {
            self.stateMachine.enterState(DecayState)
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