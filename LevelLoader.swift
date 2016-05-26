//
//  LevelLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/04/16.
//
//

import Foundation

enum LevelLoaderError: ErrorType {
    case FailedParsingLevelFile(file: String, inBundleSupportSubDirectory: String)
}

class LevelLoader: DataLoader {
    func loadLevel(levelIndex: Int) throws -> Level? {
        var levelData: Level? = nil
        
        let file = "\(levelIndex).json"
        let directory = "Levels"
        if let json = try loadJson(fromFile: file, inBundleSupportSubDirectory: directory) {
            levelData = try Level(game: game, levelIndex: levelIndex, json: json)
            print("\(json)")
        } else {
            throw LevelLoaderError.FailedParsingLevelFile(file: file, inBundleSupportSubDirectory: directory)
        }
        
        return levelData
    }    
}
