//
//  CreatureLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

class CreatureLoader: DataLoader {
    func monsterWithName(name: String, gridPosition: Point) throws -> Creature? {
        var entity: Creature? = nil
        
        let configFile = "config.json"
        let subDirectory = "Creatures/\(name)"

        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: subDirectory) {
            let configComponent = try ConfigComponent(configFileUrl: NSURL(fileURLWithPath: path))
            entity = Monster(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        } else {
            // TODO: make error
            print("could not load entity config file: \(name)/\(configFile)")
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
        
        let configFile = "config.json"
        let subDirectory = "Creatures/\(name)"
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: subDirectory) {
            if let jsonData = fileManager.contentsAtPath(path) {
                let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
                print(json)
                
                let configComponent = ConfigComponent(json: json as! [String: AnyObject])
                entity = Player(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, playerIndex: index)
            }
        } else {
            // TODO: make error
            print("could not load entity config file: \(name)/\(configFile)")
        }
        
        return entity
    }
}