//
//  Theme.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 28/04/16.
//
//

import SpriteKit

enum ThemeError: ErrorType {
    case FailedLoadingConfigFileAtURL(url: NSURL)
    case InvalidConfigDirectoryForURL(url: NSURL)
}

class Theme {
    private(set) var configFilePath: String

    private(set) var floorTilePath: String?
    private(set) var floorTileSize: CGSize?
    
    private(set) var wallTilesPath: String?
    private(set) var wallTileSize: CGSize?
    
    private(set) var breakableBlockPropName: String?
    private(set) var unbreakableBlockPropName: String?
    
    init(configFileUrl: NSURL) throws {
        let fileManager = NSFileManager.defaultManager()
        
        var json = [String: AnyObject]()
        
        guard let jsonData = fileManager.contentsAtPath(configFileUrl.path!) else {
            throw ThemeError.FailedLoadingConfigFileAtURL(url: configFileUrl)
        }
        
        json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! [String: AnyObject]
        
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
        
        guard let configFilePath = configFileUrl.URLByDeletingLastPathComponent?.path else {
            throw ThemeError.InvalidConfigDirectoryForURL(url: configFileUrl)
        }
        
        self.configFilePath = configFilePath
    }
    
    func tileNameForTileType(tileType: TileType) -> String? {
        var tileName: String? = nil
        
        if tileType == TileType.DestructableBlock {
            tileName = self.breakableBlockPropName
        } else {
            tileName = self.unbreakableBlockPropName
        }
        
        return tileName
    }
}