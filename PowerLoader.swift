//
//  PowerLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 01/06/16.
//
//

import Foundation

class PowerLoader: ConfigurationLoader {
    let configFile = "config.json"
    
    func powerWithName(name: String, gridPosition: Point) throws -> Power? {
        var power: Power? = nil
        
        let directory = "Powers/\(name)"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            power = Power(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        }
        
        return power
    }

}