//
//  TextureLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 24/05/16.
//
//

import SpriteKit

enum WallTextureType: Int {
    case Left = 0
    case Right = 1
    case Top = 2
    case Bottom = 3
    case TopLeft = 4
    case TopRight = 5
    case BottomRight = 6
    case BottomLeft = 7
}

class TextureLoader: DataLoader {
    func wallTextureForTheme(theme: Theme, type: WallTextureType) throws -> SKTexture {
        var sprites: [SKTexture] = [SKTexture]()
        
        if let textureName = theme.wallTilesPath {
            let path = theme.configFilePath!.stringByAppendingPathComponent(textureName);
            let fileUrl = NSURL(fileURLWithPath: path)
            let data = NSData(contentsOfURL: fileUrl)!
            let image = Image(data: data)?.CGImage
            let texture = SKTexture(CGImage: image!)
            sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: CGSize(width: 32, height: 32))
        }
        
        return sprites[type.rawValue]
    }
    
    func floorTextureForTheme(theme: Theme) throws -> SKTexture {
        var texture: SKTexture = SKTexture()

        if let textureName = theme.floorTilePath {
            let path = theme.configFilePath!.stringByAppendingPathComponent(textureName);
            let fileUrl = NSURL(fileURLWithPath: path)
            let data = NSData(contentsOfURL: fileUrl)!
            let image = Image(data: data)?.CGImage
            texture = SKTexture(CGImage: image!)
        }
        
        return texture
    }
    
    func tileWithName(name: String, gridPosition: Point) throws -> Tile? {
        var entity: Tile?
        
        let configFile = "config.json"
        let subDirectory = "Props/\(name)"
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: subDirectory) {
            let configComponent = try ConfigComponent(configFileUrl: NSURL(fileURLWithPath:path))
            entity = Tile(gridPosition: gridPosition, configComponent: configComponent)
        } else {
            // TODO: make error
            print("could not load entity config file: \(name)/\(configFile)")
        }
        
        return entity
    }
}