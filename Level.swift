//
//  Level.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 23/04/16.
//
//

import Foundation
import GameplayKit
import CoreGraphics
import SpriteKit

enum LevelError: ErrorType {
    case FailedLoadingTheme(fromJson: NSDictionary)
}

class Level : NSObject {
    let index: Int

    private(set) var theme: Theme
    private(set) var music: String?
    
    private(set) var width = 22
    private(set) var height = 15
    
    private(set) var tiles = [Tile?]()
    private(set) var creatures = [Creature?]()
    private(set) var props = [Prop?]()
    private(set) var powerUps = [PowerUp?]()
    
    private(set) var timer: NSTimeInterval = 60
    
    private(set) var player1: Player?
    private(set) var player2: Player?
    private(set) var game: Game
    
    // MARK: - Initialization
    
    init(game: Game, levelIndex: Int, json: NSDictionary) throws {
        self.game = game
        self.index = levelIndex
        
        let themeParser = ThemeLoader(forGame: game)
        
        guard let themeName = json.valueForKey("theme") as? String,
            let theme = try themeParser.themeWithName(themeName) else {
                throw LevelError.FailedLoadingTheme(fromJson: json)
        }
        
        self.music = json.valueForKey("music") as? String
        
        self.theme = theme
        
        super.init()

        if let layoutJson = json["layout"] {
            try parseLayout(layoutJson)
        }
        
        if let timerJson = json["timer"] as? NSTimeInterval {
            self.timer = timerJson
        }
        
        if let monstersJson = json["monsters"] as? [String: AnyObject] {
            try parseMonsters(forGame: game, json: monstersJson)
        }
        
        if let propsJson = json["props"] as? [String: AnyObject] {
            try parseProps(forGame: game, json: propsJson)
        }
        
        if let playersJson = json["players"] as? [String: AnyObject] {
            try parsePlayers(forGame: game, json: playersJson)
        }
        
        if let powersJson = json["powers"] as? [String: AnyObject] {
            try parsePowerUps(forGame: game, json: powersJson)
        }
    }
    
    // MARK: - Public
    
    func size() -> CGSize {
        let size = CGSize(width: self.width * unitLength, height: self.height * unitLength)
        return size
    }
    
    func propAtGridPosition(gridPosition: Point) -> Prop? {
        var entity: Prop?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.props[index]
        }
        
        return entity
    }
    
    func powerUpAtGridPosition(gridPosition: Point) -> PowerUp? {
        var entity: PowerUp?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.powerUps[index]
        }
        
        return entity
    }
    
    func creatureAtGridPosition(gridPosition: Point) -> Creature? {
        var entity: Creature?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.creatures[index]
        }
        
        return entity
    }
    
    func tileAtGridPosition(gridPosition: Point) -> Tile? {
        var entity: Tile?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.tiles[index]
        }
        
        return entity
    }
    
    // MARK: - Private
    
    private func indexForGridPosition(gridPosition: Point) -> Int? {
        var index: Int? = nil
        
        if (0 ..< self.width ~= gridPosition.x && 0 ..< self.height ~= gridPosition.y) {
            index = gridPosition.x + ((self.height - 1) - gridPosition.y) * self.width
        }
        
        return index
    }
}

// MARK: - Parsing

extension Level {
    private func parseLayout(json: AnyObject) throws {
        if let jsonArray = json as? NSArray {
            self.tiles.removeAll()

            var rowIndex = 0
            var colIndex = 0
            
            for (index, jsonObject) in jsonArray.enumerate() {
                colIndex = index % self.width
                rowIndex = (self.height - 1) - (index / self.width)
                
                if let jsonNumber = jsonObject as? NSNumber {
                    var tile: Tile? = nil
                    
                    if let tileType = TileType(rawValue: jsonNumber.integerValue) {
                        switch tileType {
                        case .Wall:
                            tile = try wallTileForRow(rowIndex, column: colIndex)
                        case .DestructableBlock: fallthrough
                        case .IndestructableBlock:
                            tile = try blockTileForRow(rowIndex, column: colIndex, withType: tileType)
                        case .None: break
                        }
                    }
                    
                    self.tiles.append(tile)
                    self.creatures.append(nil)
                    self.props.append(nil)
                    self.powerUps.append(nil)
                }
            }
        }
    }
    
    private func blockTileForRow(rowIndex: Int, column colIndex: Int, withType type: TileType) throws -> Tile? {
        let tileLoader = TileLoader(forGame: self.game)

        var tile: Tile?
        
        if let tileName = self.theme.tileNameForTileType(type) {
            let gridPosition = Point(x: colIndex, y: rowIndex)
            tile = try tileLoader.tileWithName(tileName, gridPosition: gridPosition, tileType: type)
        }
        
        return tile
    }
    
    private func wallTileForRow(rowIndex: Int, column colIndex: Int) throws -> Tile? {
        var tile: Tile?
        
        let tileLoader = TileLoader(forGame: self.game)
        
        var wallTextureType = WallTextureType.TopLeft
        
        if colIndex == 0 && rowIndex == 0 {
            wallTextureType = .BottomLeft
        } else if colIndex == (self.width - 1) && rowIndex == 0 {
            wallTextureType = .BottomRight
        } else if colIndex == 0 && rowIndex == (self.height - 1) {
            wallTextureType = .TopLeft
        } else if colIndex == (self.width - 1) && rowIndex == (self.height - 1) {
            wallTextureType = .TopRight
        } else if colIndex == 0 && (0 ..< self.height ~= rowIndex) {
            wallTextureType = .Left
        } else if colIndex == (self.width - 1) && (0 ..< self.height ~= rowIndex) {
            wallTextureType = .Right
        } else if rowIndex == 0 && (1 ..< (self.width - 1) ~= colIndex) {
            wallTextureType = .Bottom
        } else if rowIndex == (self.height - 1) && (1 ..< (self.width - 1) ~= colIndex) {
            wallTextureType = .Top
        }
        
        let gridPosition = Point(x: colIndex, y: rowIndex)
        tile = try tileLoader.wallTileForTheme(self.theme, type: wallTextureType, gridPosition: gridPosition)
        
        return tile
    }
    
    private func parsePowerUps(forGame game: Game, json: [String: AnyObject]) throws {
        let powerNames = json.keys
        
        let powerUpLoader = PowerUpLoader(forGame: game)
        for powerName in powerNames {
            let positions = json[powerName] as? [NSArray]
            
            for position in positions! {
                let colIndex = position.objectAtIndex(0) as! Int
                let rowIndex = position.objectAtIndex(1) as! Int
                
                let position = Point(x: colIndex, y: rowIndex)
                let index = indexForGridPosition(position)!
                
                if let powerUp = try powerUpLoader.powerUpWithName(powerName, gridPosition: position) {
                    self.powerUps[index] = powerUp
                }
            }
        }
    }
    
    private func parsePlayers(forGame game: Game, json: [String: AnyObject]) throws {
        let creatureNames = json.keys
        
        let creatureLoader = CreatureLoader(forGame: game)
        for creatureName in creatureNames {
            let values = json[creatureName] as? NSArray
            let colIndex = values?.objectAtIndex(0) as! Int
            let rowIndex = values?.objectAtIndex(1) as! Int
            
            let position = Point(x: colIndex, y: rowIndex)
            let index = indexForGridPosition(position)!
            
            switch creatureName {
            case "Player1":
                if let player = try creatureLoader.playerWithIndex(.Player1, gridPosition: position) {
                    self.creatures[index] = player
                    self.player1 = player
                }
            case "Player2":
                if let player = try creatureLoader.playerWithIndex(.Player2, gridPosition: position) {
                    self.creatures[index] = player
                    self.player2 = player
                }
            default: continue
            }
        }
    }
    
    private func parseProps(forGame game: Game, json: [String: AnyObject]) throws {
        let propNames = json.keys
        
        let propLoader = PropLoader(forGame: game)
        for propName in propNames {
            let positions = json[propName] as? [NSArray]
            
            for position in positions! {
                let colIndex = position.objectAtIndex(0) as! Int
                let rowIndex = position.objectAtIndex(1) as! Int
                
                let position = Point(x: colIndex, y: rowIndex)
                let index = indexForGridPosition(position)!
                
                if let prop = try propLoader.propWithName(propName, gridPosition: position) {
                    self.props[index] = prop
                }
            }
        }
    }
    
    private func parseMonsters(forGame game: Game, json: [String: AnyObject]) throws {
        let creatureNames = json.keys
        
        let creatureLoader = CreatureLoader(forGame: game)
        for creatureName in creatureNames {
            let positions = json[creatureName] as? [NSArray]
            
            for position in positions! {
                let colIndex = position.objectAtIndex(0) as! Int
                let rowIndex = position.objectAtIndex(1) as! Int
                
                let position = Point(x: colIndex, y: rowIndex)
                let index = indexForGridPosition(position)!
                
                if let creature = try creatureLoader.monsterWithName(creatureName, gridPosition: position) {
                    self.creatures[index] = creature
                }
            }
        }
    }
}