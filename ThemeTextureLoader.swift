//
//  TextureLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 24/05/16.
//
//

import SpriteKit

enum ThemeTextureLoaderError: ErrorType {
    case UndefinedWallTileForTheme(theme: Theme)
    case InvalidTextureCountError(expectedCount: Int, textureCount: Int)
    case FailedLoadingDataAtURL(fileUrl: NSURL)
}

// We use the rawType as the index to the texture.
enum WallTextureType: Int {
    case Left = 0
    case Right = 1
    case Top = 2
    case Bottom = 3
    case BottomLeft = 4
    case BottomRight = 5
    case TopRight = 6
    case TopLeft = 7
}

class TileLoader: ConfigurationLoader {
    func wallTileForTheme(theme: Theme, type: WallTextureType, gridPosition: Point) throws -> Tile {
        var sprites: [SKTexture] = [SKTexture]()
        
        guard let textureName = theme.wallTilesPath else {
            throw ThemeTextureLoaderError.UndefinedWallTileForTheme(theme: theme)
        }
        
        let path = theme.configFilePath.stringByAppendingPathComponent(textureName)
        let fileUrl = NSURL(fileURLWithPath: path)
            
        guard let data = NSData(contentsOfURL: fileUrl),
            let image = Image(data: data)?.CGImage else {
            throw ThemeTextureLoaderError.FailedLoadingDataAtURL(fileUrl: fileUrl)
        }
            
        let texture = SKTexture(CGImage: image)
        sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: theme.wallTileSize!)
        
        let expectedTextureCount = 8        
        guard sprites.count == expectedTextureCount else {
            throw ThemeTextureLoaderError.InvalidTextureCountError(expectedCount: expectedTextureCount,
                                                                   textureCount: sprites.count)
        }
        
        let sprite = sprites[type.rawValue]
        
        let visualComponent = VisualComponent(sprites: [sprite])
        let tile = Tile(gridPosition: gridPosition, visualComponent: visualComponent, tileType: .Wall)
        
        return tile
    }
    
    func floorTextureForTheme(theme: Theme) throws -> SKTexture {
        var texture: SKTexture = SKTexture()

        if let textureName = theme.floorTilePath {
            let path = theme.configFilePath.stringByAppendingPathComponent(textureName);
            let fileUrl = NSURL(fileURLWithPath: path)
            let data = NSData(contentsOfURL: fileUrl)!
            let image = Image(data: data)?.CGImage
            texture = SKTexture(CGImage: image!)
        }
        
        return texture
    }
    
    func tileWithName(name: String, gridPosition: Point, tileType: TileType) throws -> Tile? {
        var entity: Tile?
        
        let configFile = "config.json"
        let subDirectory = "Tiles/\(name)"
        
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: subDirectory) {
            entity = Tile(gridPosition: gridPosition, configComponent: configComponent, tileType: tileType)
        } else {
            // TODO: make error
            print("could not load entity config file: \(name)/\(configFile)")
        }
        
        return entity
    }
}