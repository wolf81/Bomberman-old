//
//  DataLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

enum DataLoaderError: Error {
    case failedLoadingFileAtPath(path: String)
}

class DataLoader {
    let game: Game
    
    fileprivate(set) var fileManager = FileManager.default

    init (forGame game: Game) {
        self.game = game
    }
    
    func loadJson(fromFile file: String, inBundleSupportSubDirectory directory: String) throws -> [String: AnyObject]? {
        var json: [String: AnyObject]?

        if let path = try fileManager.pathForFile(file, inBundleSupportSubDirectory: directory) {
            json = try loadJson(fromPath: path)
        }
        
        return json
    }
    
    func loadJson(fromPath path: String) throws -> [String: AnyObject]? {
        var json: Any?
        
        if let jsonData = fileManager.contents(atPath: path) {
            json = try JSONSerialization.jsonObject(with: jsonData, options: [])
        } else {
            throw DataLoaderError.failedLoadingFileAtPath(path: path)
        }
        
        return json as? [String: AnyObject]
    }
}
