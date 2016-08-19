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
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if let creature = entity as! Creature?,
            let visualComponent = creature.componentForClass(VisualComponent)
            where !visualComponent.spriteNode.hasActions() {
            
            creature.moveInRandomDirection()
        }
    }
}
