//
//  ConfigComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 29/04/16.
//
//

import GameplayKit
import CoreGraphics

class ConfigComponent: GKComponent {
    private(set) var configFilePath: String?
    
    private(set) var textureFile = String()
    private(set) var spriteSize = CGSize()
    
    private(set) var speed: CGFloat = 1.0
    
    private(set) var lives: Int = 0
    private(set) var health: Int = 0
    
    private(set) var spawnAnimRange             = 0 ..< 0
    private(set) var destroyAnimRange           = 0 ..< 0
    private(set) var hitAnimRange               = 0 ..< 0
    
    private(set) var moveUpAnimRange            = 0 ..< 0
    private(set) var moveDownAnimRange          = 0 ..< 0
    private(set) var moveLeftAnimRange          = 0 ..< 0
    private(set) var moveRightAnimRange         = 0 ..< 0
    
    private(set) var attackUpAnimRange          = 0 ..< 0
    private(set) var attackDownAnimRange        = 0 ..< 0
    private(set) var attackLeftAnimRange        = 0 ..< 0
    private(set) var attackRightAnimRange       = 0 ..< 0
    
    private(set) var explodeCenterAnimRange     = 0 ..< 0
    private(set) var explodeHorizontalAnimRange = 0 ..< 0
    private(set) var explodeVerticalAnimRange   = 0 ..< 0

    private(set) var destroyDelay: NSTimeInterval?
    private(set) var spawnDelay: NSTimeInterval?
    
    private(set) var destroyDuration: NSTimeInterval = 1.0
    
    private(set) var projectile: String?
    
    private(set) var states: [State]?
    
    convenience init(configFileUrl: NSURL) throws {
        let fileManager = NSFileManager.defaultManager()
        
        var json = [String: AnyObject]()
        
        if let jsonData = fileManager.contentsAtPath(configFileUrl.path!) {
            do {
                json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! [String: AnyObject]
            } catch let error as  NSError {
                print("error: \(error)")
            }
        }

        self.init(json: json)
        
        self.configFilePath = configFileUrl.URLByDeletingLastPathComponent?.path
    }
    
    init(json: [String: AnyObject]) {
        super.init()
        
        if let movementJson = json["movement"] as? [String: AnyObject] {
            parseMovementJson(movementJson)
        }
        
        if let attackJson = json["attack"] as? [String: AnyObject] {
            parseAttackJson(attackJson)
        }
        
        if let spriteJson = json["sprite"] as? [String: AnyObject] {
            parseSpriteJson(spriteJson)
        }
        
        if let statesJson = json["states"] as? [String] {
            parseStatesJson(statesJson)
        }
        
        if let creatureJson = json["creature"] as? [String: AnyObject] {
            parseCreatureJson(creatureJson)
        }
        
        if let projectileJson = json["projectile"] as? String {
            self.projectile = projectileJson
        }
        
        if let spawnJson = json["spawn"] as? [String: AnyObject] {
            self.spawnAnimRange = animRangeFromJson(spawnJson)
            
            if let spawnDelayJson = spawnJson["delay"] as? NSTimeInterval {
                self.spawnDelay = spawnDelayJson
            }
        }
        
        if let hitJson = json["hit"] as? [String: AnyObject] {
            self.hitAnimRange = animRangeFromJson(hitJson)
        }
        
        if let explodeJson = json["explode"] as? [String: AnyObject] {
            if let centerJson = explodeJson["center"] as? [String: AnyObject] {
                self.explodeCenterAnimRange = animRangeFromJson(centerJson)
            }
            if let horizontalJson = explodeJson["horizontal"] as? [String: AnyObject] {
                self.explodeHorizontalAnimRange = animRangeFromJson(horizontalJson)
            }
            if let verticalJson = explodeJson["vertical"] as? [String: AnyObject] {
                self.explodeVerticalAnimRange = animRangeFromJson(verticalJson)
            }
        }
        
        if let destroyJson = json["destroy"] as? [String: AnyObject] {
            self.destroyAnimRange = animRangeFromJson(destroyJson)
            
            if let destroyDelayJson = destroyJson["delay"] as? NSTimeInterval {
                self.destroyDelay = destroyDelayJson
            }
            
            if let destroyDurationJson = destroyJson["duration"] as? NSTimeInterval {
                self.destroyDuration = destroyDurationJson
            }
        }
    }
    
    func parseStatesJson(json: [String]) {
        var states = [State]()
        
        for stateJson in json {
            switch stateJson {
            case "roam": states.append(RoamState())
            case "destroy": states.append(DestroyState())
            case "spawn": states.append(SpawnState())
            case "attack": states.append(AttackState())
            case "hit": states.append(HitState())
            case "control": states.append(ControlState())
            case "propel": states.append(PropelState())
            default: print("unknown state: \(stateJson)")
            }
        }
        
        if states.count > 0 {
            self.states = states
        }
    }
    
    func parseCreatureJson(json: [String: AnyObject]) {
        if let livesJson = json["lives"] as? Int {
            self.lives = max(livesJson - 1, 0) // 3 lives => life 0, life 1, life 2
        }
        
        if let healthJson = json["health"] as? Int {
            self.health = max(healthJson, 0)
        }
    }
    
    func parseSpriteJson(json: [String: AnyObject]) {
        if let atlasJson = json["atlas"] as? String {
            self.textureFile = atlasJson
        }
        
        if let speedJson = json["speed"] as? CGFloat {
            self.speed = speedJson
        }
                
        if let width = json["width"] as? Int {
            if let height = json["height"] as? Int {
                self.spriteSize = CGSize(width: width, height: height)
            }
        }
    }
    
    func parseAttackJson(json: [String: AnyObject]) {
        if let attackUpJson = json["attackUp"] as? [String: AnyObject] {
            self.attackUpAnimRange = animRangeFromJson(attackUpJson)
        }
        
        if let attackDownJson = json["attackDown"] as? [String: AnyObject] {
            self.attackDownAnimRange = animRangeFromJson(attackDownJson)
        }

        if let attackLeftJson = json["attackLeft"] as? [String: AnyObject] {
            self.attackLeftAnimRange = animRangeFromJson(attackLeftJson)
        }

        if let attackRightJson = json["attackRight"] as? [String: AnyObject] {
            self.attackRightAnimRange = animRangeFromJson(attackRightJson)
        }
    }
    
    func parseMovementJson(json: [String: AnyObject]) {
        if let moveUpJson = json["moveUp"] as? [String: AnyObject] {
            self.moveUpAnimRange = animRangeFromJson(moveUpJson)
        }
        
        if let moveDownJson = json["moveDown"] as? [String: AnyObject] {
            self.moveDownAnimRange = animRangeFromJson(moveDownJson)
        }
        
        if let moveLeftJson = json["moveLeft"] as? [String: AnyObject] {
            self.moveLeftAnimRange = animRangeFromJson(moveLeftJson)
        }
        
        if let moveRightJson = json["moveRight"] as? [String: AnyObject] {
            self.moveRightAnimRange = animRangeFromJson(moveRightJson)
        }
    }
    
    func animRangeFromJson(json: [String: AnyObject]) -> Range<Int> {
        var range = Range(0 ..< 0)
        
        if let animJson = json["anim"] as? [Int] {
            if animJson.count == 2 {
                let location = animJson[0]
                let length = animJson[1]
                range = Range(location ..< (location + length))
            }
        }
        
        return range
    }
    
    // HACK
    func updateDestroyAnimRange(animRange: Range<Int>) {
        self.destroyAnimRange = animRange
    }
}