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
        
        let file = "config.json"
        let directory = "Themes/\(name)"
        
        if let path = try fileManager.pathForFile(file, inBundleSupportSubDirectory: directory) {
            theme = try Theme(configFileUrl: NSURL(fileURLWithPath: path))
        } else {
            throw DataLoaderError.FailedToCreatePathForFile(file: file, inBundleSupportSubDirectory: directory)
        }
        
        return theme
    }
}