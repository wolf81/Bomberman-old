//
//  CoinLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 17/08/16.
//
//

import Foundation

class CoinLoader : ConfigurationLoader {
    fileprivate let configFile = "config.json"

    func coinWithGridPosition(_ gridPosition: Point) throws -> Coin? {
        var coin: Coin? = nil
        
        let directory = "Coins/Coin"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            coin = Coin(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        }
        
        return coin
    }
}
