//
//  ConfigComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 29/04/16.
//
//

import GameplayKit
import CoreGraphics

enum CreatureType {
    case Monster
    case Boss
    case Undefined
}

enum AttackDirection {
    case Axial // only along x-axis & y-axis
    case Any
}

class ConfigComponent: GKComponent {
    private(set) var configFilePath: String?
    
    private(set) var textureFile = String()
    private(set) var spriteSize = CGSize()
    
    // World unit size of the entity - used for sprites that are bigger than 1 world unit.
    private(set) var wuSize = Size(width: 1, height: 1)
    
    private(set) var speed: CGFloat = 1.0
    
    private(set) var lives: Int = 0
    private(set) var health: Int = 0

    private(set) var hitDamage: Int = 1
    
    // TODO: We need to modify spawn timers for bombs, therefore this property can be modified. 
    //  Figure out cleaner solution.
    var spawnAnimation = AnimationConfiguration()
    
    private(set) var floatAnimation = AnimationConfiguration()
    private(set) var destroyAnimation = AnimationConfiguration()
    private(set) var hitAnimation = AnimationConfiguration()
    private(set) var cheerAnimation = AnimationConfiguration()
    private(set) var decayAnimation = AnimationConfiguration()
    private(set) var moveAnimation = AnimationConfiguration()
    private(set) var attackAnimation = AnimationConfiguration()
    
    private(set) var destroySound: String?
    private(set) var attackSound: String?
    private(set) var spawnSound: String?
    private(set) var hitSound: String?
    private(set) var cheerSound: String?
    
    private(set) var projectile: String?
    
    // TODO: It's better for creatureType to be irrelevant. Adjusted mechanics should be 
    //  configurable through the config file instead.
    private(set) var creatureType: CreatureType = .Undefined
    
    private(set) var attackDirection: AttackDirection = .Axial
    
    private(set) var states: [State]?
    
    private(set) var collisionCategories = EntityCategory.Nothing
    
    // MARK: - Initialization
    
    convenience init(json: [String: AnyObject], configFileUrl: NSURL) {
        self.init(json: json)

        self.configFilePath = configFileUrl.URLByDeletingLastPathComponent?.path        
    }

    init(json: [String: AnyObject]) {
        super.init()
        
        if let moveJson = json["movement"] as? [String: AnyObject] {
            if let animationJson = moveJson["animation"] as? [String: AnyObject] {
                self.moveAnimation = AnimationConfiguration(json: animationJson)
            }
        }
        
        if let attackJson = json["attack"] as? [String: AnyObject] {
            parseAttackJson(attackJson)
            
            if let animationJson = attackJson["animation"] as? [String: AnyObject] {
                self.attackAnimation = AnimationConfiguration(json: animationJson)
            }
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
            
            if let animationJson = spawnJson["animation"] as? [String: AnyObject] {
                self.spawnAnimation = AnimationConfiguration(json: animationJson)
            }
        }
        
        if let cheerJson = json["cheer"] as? [String: AnyObject] {
            parseCheerJson(cheerJson)

            if let animationJson = cheerJson["animation"] as? [String: AnyObject] {
                self.cheerAnimation = AnimationConfiguration(json: animationJson)
            }
        }
        
        if let hitJson = json["hit"] as? [String: AnyObject] {
            parseHitJson(hitJson)
            
            if let animationJson = hitJson["animation"] as? [String: AnyObject] {
                self.hitAnimation = AnimationConfiguration(json: animationJson)
            }
        }
        
        if let floatJson = json["float"] as? [String: AnyObject] {
            if let animationJson = floatJson["animation"] as? [String: AnyObject] {
                self.floatAnimation = AnimationConfiguration(json: animationJson)
            }
        }
        
        if let decayJson = json["decay"] as? [String: AnyObject] {
            if let animationJson = decayJson["animation"] as? [String: AnyObject] {
                self.decayAnimation = AnimationConfiguration(json: animationJson)
            }
        }

        if let destroyJson = json["destroy"] as? [String: AnyObject] {
            parseDestroyJson(destroyJson)
            
            if let animationJson = destroyJson["animation"] as? [String: AnyObject] {
                self.destroyAnimation = AnimationConfiguration(json: animationJson)
            }
        }
        
        if let collisionCategoriesJson = json["collisionCategories"] as? [String] {
            parseCollisionCategoriesJson(collisionCategoriesJson)
        }
    }
    
    // MARK: - Public
    
    // MARK: - Private

    private func parseStatesJson(json: [String]) {
        var states = [State]()
        
        for stateJson in json {
            switch stateJson {
            case "roam": states.append(RoamState())
            case "destroy": states.append(DestroyState())
            case "spawn": states.append(SpawnState())
            case "attack": states.append(AttackState())
            case "hit": states.append(HitState())
            case "control": states.append(ControlState())
            case "float": states.append(FloatState())
            case "cheer": states.append(CheerState())
            case "decay": states.append(DecayState())
            default: print("unknown state: \(stateJson)")
            }
        }
        
        if states.count > 0 {
            self.states = states
        }
    }
    
    private func parseCollisionCategoriesJson(json: [String]) {
        self.collisionCategories = EntityCategory.categoriesForStrings(json)
    }
    
    private func parseDestroyJson(json: [String: AnyObject]) {
        self.destroySound = soundFromJson(json)
    }
    
    private func parseHitJson(json: [String: AnyObject]) {
        self.hitSound = soundFromJson(json)        
        self.hitDamage = json["damage"] as? Int ?? 1
    }
    
    private func parseCheerJson(json: [String: AnyObject]) {
        self.cheerSound = soundFromJson(json)
    }

    private func parseSpawnJson(json: [String: AnyObject]) {
        self.spawnSound = soundFromJson(json)
    }
    
    private func parseCreatureJson(json: [String: AnyObject]) {
        if let livesJson = json["lives"] as? Int {
            self.lives = max(livesJson - 1, 0) // 3 lives => life 0, life 1, life 2
        }
        
        if let healthJson = json["health"] as? Int {
            self.health = max(healthJson, 0)
        }
        
        if let typeJson = json["type"] as? String {
            switch typeJson {
            case "monster": self.creatureType = .Monster
            case "boss": self.creatureType = .Boss
            default: self.creatureType = .Undefined
            }
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
        
        let wu_width = json["wu_width"] as? Int
        let wu_height = json["wu_height"] as? Int
        self.wuSize = Size(width: wu_width ?? 1, height: wu_height ?? 1)
    }
    
    private func parseAttackJson(json: [String: AnyObject]) {
        self.attackSound = soundFromJson(json)

        if let projectileJson = json["projectile"] as? String {
            self.projectile = projectileJson
        }
        
        if let directionJson = json["direction"] as? String {
            var attackDirection: AttackDirection
            
            switch directionJson {
            case "any": attackDirection = .Any
            case "axial": fallthrough
            default: attackDirection = .Axial
            }
            
            self.attackDirection = attackDirection
        }
    }
    
    private func soundFromJson(json: [String: AnyObject]) -> String? {
        var sound: String?
        
        if let soundJson = json["sound"] as? String {
            sound = soundJson
        }
        
        return sound
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