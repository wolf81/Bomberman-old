//
//  PropLoader.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 29/04/16.
//
//

import Foundation

class PropLoader: DataLoader {
    func tileWithName(name: String, gridPosition: Point) throws -> Tile? {
        var entity: Tile? = nil
        
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
    
    func explosionWithGridPosition(gridPosition: Point, direction: Direction) throws -> Explosion? {
        var explosion: Explosion?
        
        let configFile = "config.json"
        let subDirectory = "Props/Explosion"
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: subDirectory) {
            let configComponent = try ConfigComponent(configFileUrl: NSURL(fileURLWithPath:path))
            
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
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: subDirectory) {
            let configComponent = try ConfigComponent(configFileUrl: NSURL(fileURLWithPath:path))
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
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: subDirectory) {
            let configComponent = try ConfigComponent(configFileUrl: NSURL(fileURLWithPath:path))
            projectile = Projectile(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        } else {
            // TODO: make error
            print("could not load entity config file: Bomb\(configFile)")
        }
        
        return projectile
    }
    
    func propWithName(propName: String, gridPosition: Point) throws -> Prop? {
        var prop: Prop? = nil
        
        let configFile = "config.json"
        let subDirectory = "Props/\(propName)"
        
        if let path = try pathForFile(configFile, inBundleSupportSubDirectory: subDirectory) {
            let configComponent = try ConfigComponent(configFileUrl: NSURL(fileURLWithPath:path))
            prop = Prop(forGame: self.game, configComponent: configComponent, gridPosition: gridPosition)
        } else {
            // TODO: make error
            print("could not load entity config file: \(propName)/\(configFile)")
        }
        
        return prop
    }
}