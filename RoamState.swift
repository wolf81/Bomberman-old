//
//  RoamState.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/04/16.
//
//

import GameplayKit

class RoamState: State {
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        print("enter roam state: \(self.entity)")
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        print("exit roam state")
    }
    
    override func canUpdate() -> Bool {
        return true
    }
    
    override func updateForEntity(entity: Entity, configComponent: ConfigComponent, visualComponent: VisualComponent) {
        if let creature = entity as? Creature where !visualComponent.spriteNode.hasActions() {            
            let completion = {
                self.updating = false
                entity.delegate?.entityDidSpawn(entity)
            }
            
            creature.moveInRandomDirection(completion)
        }
    }
}
