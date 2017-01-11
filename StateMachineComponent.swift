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
        canRoam = self.stateMachine.state(forClass: MoveState.self) != nil
        return canRoam
    }

    var canAttack: Bool {
        var canAttack = false
        canAttack = self.stateMachine.state(forClass: AttackState.self) != nil
        return canAttack
    }
    
    init(game: Game, entity: Entity, states: [State]) {
        self.stateMachine = StateMachine(game: game, entity: entity, states: states)
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        self.stateMachine.update(deltaTime: seconds)
    }

    func enterRoamState() {
        self.stateMachine.enter(MoveState.self)
    }
    
    func enterAttackState() {
        self.stateMachine.enter(AttackState.self)
    }
    
    func enterSpawnState() {
        if (self.stateMachine.currentState is SpawnState) == false {
            if let creature = self.entity as? Creature, creature.lives >= 0 {
                if let configComponent = creature.component(ofType: ConfigComponent.self) {
                    creature.health = configComponent.health
                }
            }

            self.stateMachine.enter(SpawnState.self)
        }
    }
        
    func enterCheerState() {
        if (self.stateMachine.currentState is CheerState) == false {
            self.stateMachine.enter(CheerState.self)
        }
    }
    
    func enterFloatState() {
        if (self.stateMachine.currentState is FloatState) == false {
            self.stateMachine.enter(FloatState.self)
        }
    }

    func enterDecayState() {
        if (self.stateMachine.currentState is DecayState) == false {
            self.stateMachine.enter(DecayState.self)
        }
    }

    func enterDestroyState() {
        if (self.stateMachine.currentState is DestroyState) == false {
            if let creature = self.entity as? Creature {
                if creature.lives >= 0 {
                    creature.lives -= 1
                }
            }

            self.stateMachine.enter(DestroyState.self)
        }
    }
    
    func enterHitState(_ damage: Int = 1) {
        if (self.stateMachine.currentState is HitState) == false {
            if let creature = self.entity as? Creature {
                creature.health -= damage
            }
            
            self.stateMachine.enter(HitState.self)        
        }
    }
    
    func enterControlState() {
        if (self.stateMachine.currentState is ControlState) == false {
            self.stateMachine.enter(ControlState.self)
        }
    }
}
