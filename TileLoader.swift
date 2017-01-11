//
//  TextureLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 24/05/16.
//
//

import SpriteKit

enum TileLoaderError: Error {
    case undefinedWallTileForTheme(theme: Theme)
    case invalidTextureCountError(expectedCount: Int, textureCount: Int)
    case failedLoadingDataAtURL(fileUrl: URL)
}

// We use the rawType as the index to the texture.
enum WallTextureType: Int {
    case left = 0
    case right = 1
    case top = 2
    case bottom = 3
    case bottomLeft = 4
    case bottomRight = 5
    case topRight = 6
    case topLeft = 7
}

class TileLoader: ConfigurationLoader {
    func wallTileForTheme(_ theme: Theme, type: WallTextureType, gridPosition: Point) throws -> Tile {
        var sprites: [SKTexture] = [SKTexture]()
        
        guard let textureName = theme.wallTilesPath else {
            throw TileLoaderError.undefinedWallTileForTheme(theme: theme)
        }
        
        let path = theme.configFilePath.stringByAppendingPathComponent(textureName)
        let fileUrl = URL(fileURLWithPath: path)
            
        guard let data = try? Data(contentsOf: fileUrl),
            let image = Image(data: data)?.CGImage else {
            throw TileLoaderError.failedLoadingDataAtURL(fileUrl: fileUrl)
        }
            
        let texture = SKTexture(cgImage: image)
        sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: theme.wallTileSize!)
        
        let expectedTextureCount = 8        
        guard sprites.count == expectedTextureCount else {
            throw TileLoaderError.invalidTextureCountError(expectedCount: expectedTextureCount,
                                                                   textureCount: sprites.count)
        }
        
        let sprite = sprites[type.rawValue]
        
        let visualComponent = VisualComponent(sprites: [sprite])
        let tile = Tile(gridPosition: gridPosition, visualComponent: visualComponent, tileType: .wall)
        
        return tile
    }
    
    func floorTextureForTheme(_ theme: Theme) throws -> SKTexture {
        var texture: SKTexture = SKTexture()

        if let textureName = theme.floorTilePath {
            let path = theme.configFilePath.stringByAppendingPathComponent(textureName);
            let fileUrl = URL(fileURLWithPath: path)
            let data = try! Data(contentsOf: fileUrl)
            let image = Image(data: data)?.CGImage
            texture = SKTexture(cgImage: image!)
        }
        
        return texture
    }
    
    func tileWithName(_ name: String, gridPosition: Point, tileType: TileType) throws -> Tile? {
        var entity: Tile?
        
        let file = "config.json"
        let directory = "Tiles/\(name)"
        
        if let configComponent = try loadConfiguration(file, bundleSupportSubDirectory: directory) {
            entity = Tile(gridPosition: gridPosition, configComponent: configComponent, tileType: tileType)
        }
        
        return entity
    }
}
