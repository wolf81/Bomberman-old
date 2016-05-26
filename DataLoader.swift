//
//  DataLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

enum DataLoaderError: ErrorType {
    case FailedLoadingFileAtPath(path: String)
}

class DataLoader {
    let game: Game
    
    private(set) var fileManager = NSFileManager.defaultManager()

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
        var json: AnyObject?
        
        if let jsonData = fileManager.contentsAtPath(path) {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
        } else {
            throw DataLoaderError.FailedLoadingFileAtPath(path: path)
        }
        
        return json as? [String: AnyObject]
    }
}