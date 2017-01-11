//
//  LevelLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 26/04/16.
//
//

import Foundation

enum LevelLoaderError: Error {
    case failedParsingLevelFile(file: String, inBundleSupportSubDirectory: String)
}

class LevelLoader: DataLoader {
    static var levelCount: Int = LevelLoader.initLevelCount()

    func loadLevel(_ levelIndex: Int) throws -> Level {
        print("loading level: \(levelIndex)")
        
        var level: Level
        
        let file = "\(levelIndex).json"
        let directory = "Levels"
        if let json = try loadJson(fromFile: file, inBundleSupportSubDirectory: directory) {
            level = try Level(game: game, levelIndex: levelIndex, json: json as NSDictionary)
            print("\(json)")
        } else {
            throw LevelLoaderError.failedParsingLevelFile(file: file, inBundleSupportSubDirectory: directory)
        }
        
        return level
    }
    
    fileprivate static func initLevelCount() -> Int {
        var count = 0
        
        let directory = "Levels"

        let fileManager = FileManager.default
        
        var index = 0

        while (true) {
            do {
                if let path = try fileManager.pathForFile("\(index).json", inBundleSupportSubDirectory: directory) {
                    if fileManager.fileExists(atPath: path) {
                        count += 1
                        index += 1
                    } else {
                        break
                    }
                }
            } catch let error {
                print("error: \(error)")
                break
            }
        }
        
        return count
    }
}
