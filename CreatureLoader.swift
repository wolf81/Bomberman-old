//
//  CreatureLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

class CreatureLoader: ConfigurationLoader {
    fileprivate let configFile = "config.json"
    
    func monsterWithName(_ name: String, gridPosition: Point) throws -> Creature? {
        var entity: Creature? = nil
                
        let directory = "Creatures/\(name)"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            switch configComponent.creatureType {
            case .boss:
                entity = Monster(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: true, collidesWithPlayer: true)
            case .monster: fallthrough
            default:
                entity = Monster(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, createPhysicsBody: false, collidesWithPlayer: false)
            }
        }
                
        return entity
    }
    
    func playerWithIndex(_ index: PlayerIndex, gridPosition: Point) throws -> Player? {
        var entity: Player? = nil
        
        var name: String
        
        switch index {
        case .player1: name = "Player1"
        case .player2: name = "Player2"
        }
        
        let directory = "Creatures/\(name)"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            entity = Player(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, playerIndex: index)
        }
        
        return entity
    }
}
