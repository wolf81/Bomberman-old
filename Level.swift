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

enum LevelError: Error {
    case failedLoadingTheme(fromJson: NSDictionary)
}

class Level : NSObject {
    let index: Int

    fileprivate(set) var theme: Theme
    fileprivate(set) var music: String?
    
    fileprivate(set) var width = 22
    fileprivate(set) var height = 15
    
    fileprivate(set) var tiles = [Tile?]()
    fileprivate(set) var creatures = [Creature?]()
    fileprivate(set) var props = [Prop?]()
    fileprivate(set) var powerUps = [PowerUp?]()
    fileprivate(set) var coins = [Coin?]()
    
    fileprivate(set) var timer: TimeInterval = 60
    
    fileprivate(set) var player1: Player?
    fileprivate(set) var player2: Player?
    fileprivate(set) var game: Game
    
    // MARK: - Initialization
    
    init(game: Game, levelIndex: Int, json: NSDictionary) throws {
        self.game = game
        self.index = levelIndex
        
        let themeParser = ThemeLoader(forGame: game)
        
        guard let themeName = json.value(forKey: "theme") as? String,
            let theme = try themeParser.themeWithName(themeName) else {
                throw LevelError.failedLoadingTheme(fromJson: json)
        }
        
        self.music = json.value(forKey: "music") as? String
        
        self.theme = theme
        
        super.init()

        if let layoutJson = json["layout"] {
            try parseLayout(layoutJson as AnyObject)
        }
        
        if let timerJson = json["timer"] as? TimeInterval {
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
        
        if let coinsJson = json["coins"] as? [NSArray] {
            try parseCoins(forGame: game, json: coinsJson)
        }
    }
    
    // MARK: - Public
    
    func size() -> CGSize {
        let size = CGSize(width: self.width * unitLength, height: self.height * unitLength)
        return size
    }
    
    func propAtGridPosition(_ gridPosition: Point) -> Prop? {
        var entity: Prop?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.props[index]
        }
        
        return entity
    }
    
    func powerUpAtGridPosition(_ gridPosition: Point) -> PowerUp? {
        var entity: PowerUp?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.powerUps[index]
        }
        
        return entity
    }
    
    func creatureAtGridPosition(_ gridPosition: Point) -> Creature? {
        var entity: Creature?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.creatures[index]
        }
        
        return entity
    }
    
    func tileAtGridPosition(_ gridPosition: Point) -> Tile? {
        var entity: Tile?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.tiles[index]
        }
        
        return entity
    }
    
    func coinAtGridPosition(_ gridPosition: Point) -> Coin? {
        var entity: Coin?
        
        if let index = indexForGridPosition(gridPosition) {
            entity = self.coins[index]
        }
        
        return entity
    }
    
    // MARK: - Private
    
    fileprivate func indexForGridPosition(_ gridPosition: Point) -> Int? {
        var index: Int? = nil
        
        if (0 ..< self.width ~= gridPosition.x && 0 ..< self.height ~= gridPosition.y) {
            index = gridPosition.x + ((self.height - 1) - gridPosition.y) * self.width
        }
        
        return index
    }
}

// MARK: - Parsing

extension Level {
    fileprivate func parseLayout(_ json: AnyObject) throws {
        if let jsonArray = json as? NSArray {
            self.tiles.removeAll()

            var rowIndex = 0
            var colIndex = 0
            
            for (index, jsonObject) in jsonArray.enumerated() {
                colIndex = index % self.width
                rowIndex = (self.height - 1) - (index / self.width)
                
                if let jsonNumber = jsonObject as? NSNumber {
                    var tile: Tile? = nil
                    
                    if let tileType = TileType(rawValue: jsonNumber.intValue) {
                        switch tileType {
                        case .wall:
                            tile = try wallTileForRow(rowIndex, column: colIndex)
                        case .destructableBlock: fallthrough
                        case .indestructableBlock:
                            tile = try blockTileForRow(rowIndex, column: colIndex, withType: tileType)
                        case .none: break
                        }
                    }
                    
                    self.tiles.append(tile)
                    self.creatures.append(nil)
                    self.props.append(nil)
                    self.powerUps.append(nil)
                    self.coins.append(nil)
                }
            }
        }
    }
    
    fileprivate func blockTileForRow(_ rowIndex: Int, column colIndex: Int, withType type: TileType) throws -> Tile? {
        let tileLoader = TileLoader(forGame: self.game)

        var tile: Tile?
        
        if let tileName = self.theme.tileNameForTileType(type) {
            let gridPosition = Point(x: colIndex, y: rowIndex)
            tile = try tileLoader.tileWithName(tileName, gridPosition: gridPosition, tileType: type)
        }
        
        return tile
    }
    
    fileprivate func wallTileForRow(_ rowIndex: Int, column colIndex: Int) throws -> Tile? {
        var tile: Tile?
        
        let tileLoader = TileLoader(forGame: self.game)
        
        var wallTextureType = WallTextureType.topLeft
        
        if colIndex == 0 && rowIndex == 0 {
            wallTextureType = .bottomLeft
        } else if colIndex == (self.width - 1) && rowIndex == 0 {
            wallTextureType = .bottomRight
        } else if colIndex == 0 && rowIndex == (self.height - 1) {
            wallTextureType = .topLeft
        } else if colIndex == (self.width - 1) && rowIndex == (self.height - 1) {
            wallTextureType = .topRight
        } else if colIndex == 0 && (0 ..< self.height ~= rowIndex) {
            wallTextureType = .left
        } else if colIndex == (self.width - 1) && (0 ..< self.height ~= rowIndex) {
            wallTextureType = .right
        } else if rowIndex == 0 && (1 ..< (self.width - 1) ~= colIndex) {
            wallTextureType = .bottom
        } else if rowIndex == (self.height - 1) && (1 ..< (self.width - 1) ~= colIndex) {
            wallTextureType = .top
        }
        
        let gridPosition = Point(x: colIndex, y: rowIndex)
        tile = try tileLoader.wallTileForTheme(self.theme, type: wallTextureType, gridPosition: gridPosition)
        
        return tile
    }
    
    fileprivate func parseCoins(forGame game: Game, json: [NSArray]) throws {
        let coinLoader = CoinLoader(forGame: game)

        for position in json {
            let colIndex = position.object(at: 0) as! Int
            let rowIndex = position.object(at: 1) as! Int
            
            let position = Point(x: colIndex, y: rowIndex)
            let index = indexForGridPosition(position)!
            
            if let coin = try coinLoader.coinWithGridPosition(position) {
                self.coins[index] = coin
            }
        }
    }
    
    fileprivate func parsePowerUps(forGame game: Game, json: [String: AnyObject]) throws {
        let powerNames = json.keys
        
        let powerUpLoader = PowerUpLoader(forGame: game)
        for powerName in powerNames {
            let positions = json[powerName] as? [NSArray]
            
            for position in positions! {
                let colIndex = position.object(at: 0) as! Int
                let rowIndex = position.object(at: 1) as! Int
                
                let position = Point(x: colIndex, y: rowIndex)
                let index = indexForGridPosition(position)!
                
                if let powerUp = try powerUpLoader.powerUpWithName(powerName, gridPosition: position) {
                    self.powerUps[index] = powerUp
                }
            }
        }
    }
    
    fileprivate func parsePlayers(forGame game: Game, json: [String: AnyObject]) throws {
        let creatureNames = json.keys
        
        let creatureLoader = CreatureLoader(forGame: game)
        for creatureName in creatureNames {
            let values = json[creatureName] as? NSArray
            let colIndex = values?.object(at: 0) as! Int
            let rowIndex = values?.object(at: 1) as! Int
            
            let position = Point(x: colIndex, y: rowIndex)
            let index = indexForGridPosition(position)!
            
            switch creatureName {
            case "Player1":
                if let player = try creatureLoader.playerWithIndex(.player1, gridPosition: position) {
                    self.creatures[index] = player
                    self.player1 = player
                }
            case "Player2":
                if let player = try creatureLoader.playerWithIndex(.player2, gridPosition: position) {
                    self.creatures[index] = player
                    self.player2 = player
                }
            default: continue
            }
        }
    }
    
    fileprivate func parseProps(forGame game: Game, json: [String: AnyObject]) throws {
        let propNames = json.keys
        
        let propLoader = PropLoader(forGame: game)
        for propName in propNames {
            let positions = json[propName] as? [NSArray]
            
            for position in positions! {
                let colIndex = position.object(at: 0) as! Int
                let rowIndex = position.object(at: 1) as! Int
                
                let position = Point(x: colIndex, y: rowIndex)
                let index = indexForGridPosition(position)!
                
                if let prop = try propLoader.propWithName(propName, gridPosition: position) {
                    self.props[index] = prop
                }
            }
        }
    }
    
    fileprivate func parseMonsters(forGame game: Game, json: [String: AnyObject]) throws {
        let creatureNames = json.keys
        
        let creatureLoader = CreatureLoader(forGame: game)
        for creatureName in creatureNames {
            let positions = json[creatureName] as? [NSArray]
            
            for position in positions! {
                let colIndex = position.object(at: 0) as! Int
                let rowIndex = position.object(at: 1) as! Int
                
                let position = Point(x: colIndex, y: rowIndex)
                let index = indexForGridPosition(position)!
                
                if let creature = try creatureLoader.monsterWithName(creatureName, gridPosition: position) {
                    self.creatures[index] = creature
                }
            }
        }
    }
}
