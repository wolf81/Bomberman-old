//
//  ConfigLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/05/16.
//
//

import Foundation

class ConfigLoader: DataLoader {
    func loadConfiguration(configFile: String, bundleSupportSubDirectory: String) throws -> ConfigComponent? {
        var configComponent: ConfigComponent?
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: bundleSupportSubDirectory) {
            if let json = try jsonData(fromPath: path) {
                let url = NSURL(fileURLWithPath: path)
                configComponent = ConfigComponent(json: json, configFileUrl: url)
            }
        } else {
            print("could not create path for: \(bundleSupportSubDirectory)\\\(configFile)")
        }
 
        return configComponent
    }
}