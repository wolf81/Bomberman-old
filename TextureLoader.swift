//
//  TextureLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 24/05/16.
//
//

import SpriteKit

class TextureLoader: DataLoader {
    func floorTextureForTheme(theme: Theme) throws -> SKTexture {
        var texture: SKTexture = SKTexture()

        if let textureName = theme.floorTile {
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