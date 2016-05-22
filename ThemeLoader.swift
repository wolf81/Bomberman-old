//
//  ThemeParser.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 28/04/16.
//
//

import Foundation

class ThemeLoader: DataLoader {
    func themeWithName(name: String) throws -> Theme? {
        var theme: Theme? = nil
        
        let configFile = "config.json"
        let subDirectory = "Themes/\(name)"
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: subDirectory) {
            if let jsonData = fileManager.contentsAtPath(path) {
                let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
                print(json)
                
                theme = Theme(json: json as! [String: AnyObject])
            }
        } else {
            // TODO: make error
            print("could not load entity config file: \(name)/\(configFile)")
        }
        
        return theme
    }
}