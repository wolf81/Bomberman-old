//
//  Theme.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 28/04/16.
//
//

import SpriteKit

enum ThemeError: Error {
    case failedLoadingConfigFileAtURL(url: URL)
//    case invalidConfigDirectoryForURL(url: URL)
}

class Theme {
    fileprivate(set) var configFilePath: String

    fileprivate(set) var floorTilePath: String?
    fileprivate(set) var floorTileSize: CGSize?
    
    fileprivate(set) var wallTilesPath: String?
    fileprivate(set) var wallTileSize: CGSize?
    
    fileprivate(set) var breakableBlockPropName: String?
    fileprivate(set) var unbreakableBlockPropName: String?
    
    init(configFileUrl: URL) throws {
        let fileManager = FileManager.default
        
        var json = [String: AnyObject]()
        
        guard let jsonData = fileManager.contents(atPath: configFileUrl.path) else {
            throw ThemeError.failedLoadingConfigFileAtURL(url: configFileUrl)
        }
        
        json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
        
        if let floorTilesDict = json["floorTiles"] as! [String: AnyObject]? {
            if let spriteDict = floorTilesDict["sprite"] as! [String: AnyObject]? {
                self.floorTilePath = spriteDict["atlas"] as! String?
            }
        }
        
        if let borderTilesDict = json["borderTiles"] as! [String: AnyObject]? {
            if let spriteDict = borderTilesDict["sprite"] as! [String: AnyObject]? {
                self.wallTilesPath = spriteDict["atlas"] as! String?
                
                if let width = spriteDict["width"] as? Int {
                    if let height = spriteDict["height"] as? Int {
                        self.wallTileSize = CGSize(width: width, height: height)
                    }
                }
            }
        }
        
        if let blockEntitiesJson = json["blockEntities"] as! [String: AnyObject]? {
            if let breakableBlockJson = blockEntitiesJson["breakableBlock"] as! String? {
                self.breakableBlockPropName = breakableBlockJson
            }
            if let unbreakableBlockJson = blockEntitiesJson["unbreakableBlock"] as! String? {
                self.unbreakableBlockPropName = unbreakableBlockJson
            }
        }
        
        let configFilePath = configFileUrl.deletingLastPathComponent().path
        
        self.configFilePath = configFilePath
    }
    
    func tileNameForTileType(_ tileType: TileType) -> String? {
        var tileName: String? = nil
        
        if tileType == TileType.destructableBlock {
            tileName = self.breakableBlockPropName
        } else {
            tileName = self.unbreakableBlockPropName
        }
        
        return tileName
    }
}
