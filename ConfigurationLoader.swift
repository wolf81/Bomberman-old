//
//  ConfigLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/05/16.
//
//

import Foundation

class ConfigurationLoader: DataLoader {
    func loadConfiguration(_ file: String, bundleSupportSubDirectory directory: String) throws -> ConfigComponent? {
        var configComponent: ConfigComponent?
        
        if let path = try fileManager.pathForFile(file, inBundleSupportSubDirectory: directory) {
            if let json = try loadJson(fromPath: path) {
                let url = URL(fileURLWithPath: path)
                configComponent = ConfigComponent(json: json, configFileUrl: url)
            }
        }
 
        return configComponent
    }
}
