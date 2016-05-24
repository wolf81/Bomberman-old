//
//  Theme.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 28/04/16.
//
//

import SpriteKit

class Theme {
    private(set) var configFilePath: String?

    private(set) var floorTile: String?
    
    private(set) var topWallTile: SKTexture?
    private(set) var bottomWallTile: SKTexture?
    private(set) var leftWallTile: SKTexture?
    private(set) var rightWallTile: SKTexture?

    private(set) var topLeftCornerTile: SKTexture?
    private(set) var topRightCornerTile: SKTexture?
    private(set) var bottomLeftCornerTile: SKTexture?
    private(set) var bottomRightCornerTile: SKTexture?
    
    private(set) var breakableBlockPropName: String?
    private(set) var unbreakableBlockPropName: String?
    
    convenience init(configFileUrl: NSURL) throws {
        let fileManager = NSFileManager.defaultManager()
        
        var json = [String: AnyObject]()
        
        if let jsonData = fileManager.contentsAtPath(configFileUrl.path!) {
            do {
                json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! [String: AnyObject]
            } catch let error as  NSError {
                print("error: \(error)")
            }
        }
        
        self.init(json: json)
        
        self.configFilePath = configFileUrl.URLByDeletingLastPathComponent?.path
    }

    init(json: [String: AnyObject]) {
        // floorTiles.sprite.atlas / width / height
        var floorTile: String?
        
        if let floorTilesDict = json["floorTiles"] as! [String: AnyObject]? {
            if let spriteDict = floorTilesDict["sprite"] as! [String: AnyObject]? {
                floorTile = spriteDict["atlas"] as! String?
            }
        }
        
        self.floorTile = floorTile!

        var borderTexture: SKTexture?
        
        if let borderTilesDict = json["borderTiles"] as! [String: AnyObject]? {
            if let spriteDict = borderTilesDict["sprite"] as! [String: AnyObject]? {
                if let atlasName = spriteDict["atlas"] as! String? {
                    borderTexture = SKTexture(imageNamed: atlasName)
                }
            }
        }
        
        if borderTexture != nil {
            let spriteSize = CGSize(width: 32, height: 32)
            let borderSprites = SpriteLoader.spritesFromTexture(borderTexture!, withSpriteSize: spriteSize)
            
            self.leftWallTile = borderSprites[0]
            self.rightWallTile = borderSprites[1]
            self.topWallTile = borderSprites[2]
            self.bottomWallTile = borderSprites[3]
            
            self.topLeftCornerTile = borderSprites[7]
            self.topRightCornerTile = borderSprites[6]
            self.bottomRightCornerTile = borderSprites[5]
            self.bottomLeftCornerTile = borderSprites[4]
        }
        
        if let blockEntitiesJson = json["blockEntities"] as! [String: AnyObject]? {
            if let breakableBlockJson = blockEntitiesJson["breakableBlock"] as! String? {
                self.breakableBlockPropName = breakableBlockJson
            }
            if let unbreakableBlockJson = blockEntitiesJson["unbreakableBlock"] as! String? {
                self.unbreakableBlockPropName = unbreakableBlockJson
            }
        }
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