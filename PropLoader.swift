//
//  PropLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 29/04/16.
//
//

import Foundation

class PropLoader: ConfigurationLoader {
    private let configFile = "config.json"
        
    func explosionWithGridPosition(gridPosition: Point, direction: Direction) throws -> Explosion? {
        var explosion: Explosion?
        
        let directory = "Props/Explosion"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            explosion = Explosion(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
            explosion?.direction = direction
        }

        return explosion
    }
    
    func bombWithGridPosition(gridPosition: Point, player: PlayerIndex) throws -> Bomb? {
        var bomb: Bomb? = nil
        
        let directory = "Props/Bomb"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            bomb = Bomb(forGame: self.game,
                        player: player,
                        configComponent: configComponent,
                        gridPosition: gridPosition)
        }
        
        return bomb
    }
    
    func projectileWithName(name: String, gridPosition: Point) throws -> Projectile? {
        var projectile: Projectile? = nil
        
        let directory = "Props/\(name)"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            projectile = Projectile(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        }
        
        return projectile
    }
    
    func pointsWithType(pointsType: PointsType, gridPosition: Point) throws -> Points? {
        var points: Points? = nil
        
        let directory = "Props/Points10"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            points = Points(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, type: pointsType)
        }
        
        return points
    }
    
    func propWithName(propName: String, gridPosition: Point) throws -> Prop? {
        var prop: Prop? = nil
        
        let directory = "Props/\(propName)"
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: directory) {
            prop = Prop(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        }
        
        return prop
    }
}