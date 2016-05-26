//
//  LevelLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/04/16.
//
//

import Foundation

class LevelLoader: DataLoader {
    func loadLevel(levelIndex: Int) throws -> Level? {
        var levelData: Level? = nil
        let configFile = "\(levelIndex).json"
        
        if let json = try loadJson(fromFile: configFile, inBundleSupportSubDirectory: "Levels") {
            levelData = try Level(game: game, levelIndex: levelIndex, json: json)
            print("\(json)")
        } else {
            // TODO: make error
            print("could not load level config file: \(configFile)")
        }
        
        return levelData
    }    
}
