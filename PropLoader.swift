//
//  PropLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 29/04/16.
//
//

import Foundation

enum PointsType: Int {
    case Ten = 10
    case Fifty = 50
    case Hundred = 100
}

class PropLoader: ConfigLoader {
    func powerWithGridPosition(gridPosition: Point, type: PowerType) throws -> Power? {
        var entity: Power? = nil
        
        let configFile = "config.json"
        let subDirectory = "Props/Power"
        
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: subDirectory) {
            entity = Power(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, type: type)
        } else {
            // TODO: make error
            print("could not load entity config file: Power\(configFile)")
        }
        
        return entity
    }
    
    func explosionWithGridPosition(gridPosition: Point, direction: Direction) throws -> Explosion? {
        var explosion: Explosion?
        
        let configFile = "config.json"
        let subDirectory = "Props/Explosion"
        
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: subDirectory) {
            switch direction {
            case .North: configComponent.updateDestroyAnimRange(configComponent.explodeVerticalAnimRange)
            case .South: configComponent.updateDestroyAnimRange(configComponent.explodeVerticalAnimRange)
            case .East: configComponent.updateDestroyAnimRange(configComponent.explodeHorizontalAnimRange)
            case .West: configComponent.updateDestroyAnimRange(configComponent.explodeHorizontalAnimRange)
            default: configComponent.updateDestroyAnimRange(configComponent.explodeCenterAnimRange)
            }
            
            explosion = Explosion(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        } else {
            // TODO: make error
            print("could not load entity config file: Bomb\(configFile)")
        }

        return explosion
    }
    
    func bombWithGridPosition(gridPosition: Point) throws -> Bomb? {
        var bomb: Bomb? = nil
        
        let configFile = "config.json"
        let subDirectory = "Props/Bomb"
        
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: subDirectory) {
            bomb = Bomb(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        } else {
            // TODO: make error
            print("could not load entity config file: Bomb\(configFile)")
        }
        
        return bomb
    }
    
    func projectileWithName(name: String, gridPosition: Point) throws -> Projectile? {
        var projectile: Projectile? = nil
        
        let configFile = "config.json"
        let subDirectory = "Props/\(name)"
        
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: subDirectory) {
            projectile = Projectile(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        } else {
            // TODO: make error
            print("could not load entity config file: Bomb\(configFile)")
        }
        
        return projectile
    }
    
    func pointsWithType(pointsType: PointsType, gridPosition: Point) throws -> Points? {
        var points: Points? = nil
        
        let configFile = "config.json"
        let subDirectory = "Props/Points10"
        
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: subDirectory) {
            points = Points(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition, type: pointsType)
        } else {
            // TODO: make error
            print("could not load entity config file: \(subDirectory)\\\(configFile)")
        }
        
        return points
    }
    
    func propWithName(propName: String, gridPosition: Point) throws -> Prop? {
        var prop: Prop? = nil
        
        let configFile = "config.json"
        let subDirectory = "Props/\(propName)"
        
        if let configComponent = try loadConfiguration(configFile, bundleSupportSubDirectory: subDirectory) {
            prop = Prop(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        } else {
            // TODO: make error
            print("could not load entity config file: \(propName)/\(configFile)")
        }
        
        return prop
    }
}