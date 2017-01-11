//
//  PowerLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 01/06/16.
//
//

import Foundation

class PowerUpLoader: ConfigurationLoader {
    let configFile = "config.json"
    
    func powerUpWithName(_ name: String, gridPosition: Point) throws -> PowerUp? {
        var powerUp: PowerUp? = nil
        
        let directory = "Powers/\(name)"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            powerUp = PowerUp(forGame: self.game,
                              configComponent: configComponent,
                              gridPosition: gridPosition,
                              power: powerTypeForName(name))
        }
        
        return powerUp
    }
    
    // MARK: - Private
    
    fileprivate func powerTypeForName(_ name: String) -> PowerType {
        var power: PowerType
        
        switch name {
        case "Explosion":       power = .explosionSize
        case "Heal":            power = .heal
        case "HealAll":         power = .healAll
        case "BombAdd":         power = .bombAdd
        case "BombSpeed":       power = .bombSpeed
        case "MoveSpeed":       power = .moveSpeed
        case "Shield":          power = .shield
        case "DestroyMonsters": power = .destroyMonsters
        case "DestroyBlocks":   power = .destroyBlocks
        default:                power = .unknown
        }
        
        return power
    }
}
