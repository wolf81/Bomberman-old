//
//  DataLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

// TODO: Proper error handling

class DataLoader {
    let game: Game
    
    init (forGame game: Game) {
        self.game = game
    }
    
    let fileManager = NSFileManager.defaultManager()
    
    func pathForBundleSupportSubDirectory(directory: String, createIfNotExists: Bool) throws -> String? {
        var path: String? = nil
        
        path = fileManager.bundleSupportDirectoryPath()
        
        if path != nil {
            path = path!.stringByAppendingPathComponent(directory)
        }
        
        var isDirectory: ObjCBool = false
        if !fileManager.fileExistsAtPath(path!, isDirectory: &isDirectory) {
            try fileManager.createDirectoryAtPath(path!, withIntermediateDirectories: false, attributes: nil)
        }
        
        return path
    }
    
    func pathForFile(file: String, inBundleSupportSubDirectory directory: String) throws -> String? {
        var path: String? = nil
        
        path = try pathForBundleSupportSubDirectory(directory, createIfNotExists: true)
        path = path?.stringByAppendingPathComponent(file)
        
        return path
   }

    func jsonData(fromPath path: String) throws -> [String: AnyObject]? {
        var json: AnyObject? = nil
        
        if let jsonData = fileManager.contentsAtPath(path) {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
        } else {
            print("could not load file at path: \(path)")
        }
        
        return json as? [String: AnyObject]
    }
}