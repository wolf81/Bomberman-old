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
    private(set) var cheerAnimRange             = 0 ..< 0
    
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

    private(set) var spawnDelay: NSTimeInterval = 0
    
    private(set) var destroyAnimRepeat = 1
    
    private(set) var destroySound: String?
    private(set) var spawnSound: String?
    private(set) var hitSound: String?
    private(set) var cheerSound: String?
    
    private(set) var floatDuration: NSTimeInterval = 1.0
    private(set) var spawnDuration: NSTimeInterval = 1.0
    private(set) var destroyDuration: NSTimeInterval = 1.0
    private(set) var cheerDuration: NSTimeInterval = 1.0
    
    private(set) var projectile: String?
    
    private(set) var states: [State]?
    
    // MARK: - Initialization
    
    convenience init(json: [String: AnyObject], configFileUrl: NSURL) {
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
        
        if let spawnJson = json["spawn"] as? [String: AnyObject] {
            parseSpawnJson(spawnJson)
        }
        
        if let cheerJson = json["cheer"] as? [String: AnyObject] {
            parseCheerJson(cheerJson)
        }
        
        if let floatJson = json["float"] as? [String: AnyObject] {
            parseFloatJson(floatJson)
        }
        
        if let hitJson = json["hit"] as? [String: AnyObject] {
            parseHitJson(hitJson)
        }
        
        if let json = json["explode"] as? [String: AnyObject] {
            parseExplodeJson(json)
        }
        
        if let destroyJson = json["destroy"] as? [String: AnyObject] {
            parseDestroyJson(destroyJson)
        }
    }
    
    // MARK: - Public
    
    // WORKAROUND: for explosions to change animRange depending on explosion direction
    func updateDestroyAnimRange(animRange: Range<Int>) {
        self.destroyAnimRange = animRange
    }
    
    // MARK: - Private

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
            case "float": states.append(FloatState())
            case "cheer": states.append(CheerState())
            default: print("unknown state: \(stateJson)")
            }
        }
        
        if states.count > 0 {
            self.states = states
        }
    }
    
    private func parseExplodeJson(json: [String: AnyObject]) {
        if let centerJson = json["center"] as? [String: AnyObject] {
            self.explodeCenterAnimRange = animRangeFromJson(centerJson)
        }
        
        if let horizontalJson = json["horizontal"] as? [String: AnyObject] {
            self.explodeHorizontalAnimRange = animRangeFromJson(horizontalJson)
        }
        
        if let verticalJson = json["vertical"] as? [String: AnyObject] {
            self.explodeVerticalAnimRange = animRangeFromJson(verticalJson)
        }
    }

    private func parseDestroyJson(json: [String: AnyObject]) {
        self.destroyAnimRange = animRangeFromJson(json)
        self.destroyDuration = durationFromJson(json)
        self.destroySound = soundFromJson(json)

        if let repeatJson = json["repeat"] as? Int {
            self.destroyAnimRepeat = repeatJson
        }
    }
    
    private func parseHitJson(json: [String: AnyObject]) {
        self.hitAnimRange = animRangeFromJson(json)
        self.hitSound = soundFromJson(json)
    }
    
    private func parseFloatJson(json: [String: AnyObject]) {
        self.floatDuration = durationFromJson(json)
    }
    
    private func parseCheerJson(json: [String: AnyObject]) {
        self.cheerAnimRange = animRangeFromJson(json)
        self.cheerDuration = durationFromJson(json)
        self.cheerSound = soundFromJson(json)
    }

    private func parseSpawnJson(json: [String: AnyObject]) {
        self.spawnAnimRange = animRangeFromJson(json)
        self.spawnDelay = delayFromJson(json) ?? 0.0
        self.spawnDuration = durationFromJson(json)
        self.spawnSound = soundFromJson(json)
    }
    
    private func parseCreatureJson(json: [String: AnyObject]) {
        if let livesJson = json["lives"] as? Int {
            self.lives = max(livesJson - 1, 0) // 3 lives => life 0, life 1, life 2
        }
        
        if let healthJson = json["health"] as? Int {
            self.health = max(healthJson, 0)
        }
    }
    
    private func parseSpriteJson(json: [String: AnyObject]) {
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
    
    private func parseAttackJson(json: [String: AnyObject]) {
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
        
        if let projectileJson = json["projectile"] as? String {
            self.projectile = projectileJson
        }
    }
    
    private func parseMovementJson(json: [String: AnyObject]) {
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
    
    private func durationFromJson(json: [String: AnyObject]) -> NSTimeInterval {
        var duration: NSTimeInterval = 1.0
        
        if let durationJson = json["duration"] as? NSTimeInterval {
            duration = durationJson
        }
        
        return duration
    }
    
    private func soundFromJson(json: [String: AnyObject]) -> String? {
        var sound: String?
        
        if let soundJson = json["sound"] as? String {
            sound = soundJson
        }
        
        return sound
    }
    
    private func delayFromJson(json: [String: AnyObject]) -> NSTimeInterval? {
        var delay: NSTimeInterval?
        
        if let delayJson = json["delay"] as? NSTimeInterval {
            delay = delayJson
        }
        
        return delay
    }
    
    private func animRangeFromJson(json: [String: AnyObject]) -> Range<Int> {
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
}