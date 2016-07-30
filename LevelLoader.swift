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
    static var levelCount: Int = LevelLoader.initLevelCount()

    func loadLevel(levelIndex: Int) throws -> Level {
        print("loading level: \(levelIndex)")
        
        var level: Level
        
        let file = "\(levelIndex).json"
        let directory = "Levels"
        if let json = try loadJson(fromFile: file, inBundleSupportSubDirectory: directory) {
            level = try Level(game: game, levelIndex: levelIndex, json: json)
            print("\(json)")
        } else {
            throw LevelLoaderError.FailedParsingLevelFile(file: file, inBundleSupportSubDirectory: directory)
        }
        
        return level
    }
    
    private static func initLevelCount() -> Int {
        var count = 0
        
        let directory = "Levels"

        let fileManager = NSFileManager.defaultManager()
        
        var index = 0

        while (true) {
            do {
                if let path = try fileManager.pathForFile("\(index).json", inBundleSupportSubDirectory: directory) {
                    if fileManager.fileExistsAtPath(path) {
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
