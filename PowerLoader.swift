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
    
    func powerUpWithName(name: String, gridPosition: Point) throws -> PowerUp? {
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
    
    private func powerTypeForName(name: String) -> PowerType {
        var power: PowerType
        
        switch name {
        case "Explosion":       power = .ExplosionSize
        case "Heal":            power = .Heal
        case "HealAll":         power = .HealAll
        case "BombAdd":         power = .BombAdd
        case "BombSpeed":       power = .BombSpeed
        case "Shield":          power = .Shield
        case "DestroyMonsters": power = .DestroyMonsters
        case "DestroyBlocks":   power = .DestroyBlocks
        default:                power = .Unknown
        }
        
        return power
    }
}