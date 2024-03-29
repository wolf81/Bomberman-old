//
//  ThemeParser.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 28/04/16.
//
//

import Foundation

class ThemeLoader: DataLoader {
    func themeWithName(_ name: String) throws -> Theme? {
        var theme: Theme? = nil
        
        let file = "config.json"
        let directory = "Themes/\(name)"
        
        if let path = try fileManager.pathForFile(file, inBundleSupportSubDirectory: directory) {
            theme = try Theme(configFileUrl: URL(fileURLWithPath: path))
        }
        
        return theme
    }
}
