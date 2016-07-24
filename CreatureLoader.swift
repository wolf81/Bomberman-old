//
//  CreatureLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

class CreatureLoader: ConfigurationLoader {
    private let configFile = "config.json"
    
    func monsterWithName(name: String, gridPosition: Point) throws -> Creature? {
        var entity: Creature? = nil
        
        let directory = "Creatures/\(name)"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            switch configComponent.creatureType {
            case .Boss:
                entity = Monster(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: true, collidesWithPlayer: true)
            case .Monster: fallthrough
            default:
                entity = Monster(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: false, collidesWithPlayer: false)
            }
        }
                
        return entity
    }
    
    func playerWithIndex(index: PlayerIndex, gridPosition: Point) throws -> Player? {
        var entity: Player? = nil
        
        var name: String
        
        switch index {
        case .Player1: name = "Player1"
        case .Player2: name = "Player2"
        }
        
        let directory = "Creatures/\(name)"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            entity = Player(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, playerIndex: index)
        }
        
        return entity
    }
}