//
//  RoamState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit

class RoamState: State {
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        print("enter roam state: \(String(describing: self.entity))")
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        print("exit roam state")
    }
    
    override func canUpdate() -> Bool {
        return true
    }
    
    override func updateForEntity(_ entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent, didUpdate: @escaping () -> Void) {
        if let creature = entity as? Creature, !visualComponent.spriteNode.hasActions() {
            let completion = {
                didUpdate()
                entity.delegate?.entityDidSpawn(entity)
            }
            
            creature.moveInRandomDirection(completion)
        }
    }
}
