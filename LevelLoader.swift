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
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: "Levels") {
            if let jsonData = fileManager.contentsAtPath(path) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
                    levelData = Level(game: game, levelIndex: levelIndex, json: json as! NSDictionary)
                    print("\(json)")
                } catch let error as  NSError {
                    print("error: \(error)")
                }
            }
        } else {
            // TODO: make error
            print("could not load level config file: \(configFile)")
        }
        
        return levelData
    }    
}
