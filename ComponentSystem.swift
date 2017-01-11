//
//  ComponentSystem.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 29/05/16.
//
//

import GameplayKit

class ComponentSystem: GKComponentSystem<GKComponent> {
    func removeAllComponents() {
        let components = self.components
        
        for component in components {
            removeComponent(component)
        }
    }
}
