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
    case monster
    case boss
    case undefined
}

enum AttackDirection {
    case axial // only along x-axis & y-axis
    case radial
}

class ConfigComponent: GKComponent {
    fileprivate(set) var configFilePath: String
    
    fileprivate(set) var textureFile = String()
    fileprivate(set) var spriteSize = CGSize()
    
    // World unit size of the entity - used for sprites that are bigger than 1 world unit.
    fileprivate(set) var wuSize = Size(width: 1, height: 1)
    
    fileprivate(set) var speed: CGFloat = 1.0
    
    fileprivate(set) var lives: Int = 0
    fileprivate(set) var health: Int = 0

    fileprivate(set) var hitDamage: Int = 1
    
    // TODO: We need to modify spawn timers for bombs, therefore this property can be modified. 
    //  Figure out cleaner solution.
    var spawnAnimation = AnimationConfiguration()
    
    fileprivate(set) var floatAnimation = AnimationConfiguration()
    fileprivate(set) var destroyAnimation = AnimationConfiguration()
    fileprivate(set) var hitAnimation = AnimationConfiguration()
    fileprivate(set) var cheerAnimation = AnimationConfiguration()
    fileprivate(set) var decayAnimation = AnimationConfiguration()
    fileprivate(set) var moveAnimation = AnimationConfiguration()
    fileprivate(set) var attackAnimation = AnimationConfiguration()
    
    fileprivate(set) var destroySound: String?
    fileprivate(set) var attackSound: String?
    fileprivate(set) var spawnSound: String?
    fileprivate(set) var hitSound: String?
    fileprivate(set) var cheerSound: String?
    
    fileprivate(set) var projectile: String?
    
    // TODO: It's better for creatureType to be irrelevant. Adjusted mechanics should be 
    //  configurable through the config file instead.
    fileprivate(set) var creatureType: CreatureType = .undefined
    
    fileprivate(set) var attackDirection: AttackDirection = .axial
    
    fileprivate(set) var states: [State]?
    
    fileprivate(set) var collisionCategories = EntityCategory.Nothing
    
    // MARK: - Initialization
    
    init(json: [String: AnyObject], configFileUrl: URL) {
        self.configFilePath = configFileUrl.deletingLastPathComponent().path

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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    // MARK: - Private

    fileprivate func parseStatesJson(_ json: [String]) {
        var states = [State]()
        
        for stateJson in json {
            switch stateJson {
            case "roam": states.append(MoveState())
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
    
    fileprivate func parseCollisionCategoriesJson(_ json: [String]) {
        self.collisionCategories = EntityCategory.categoriesForStrings(json)
    }
    
    fileprivate func parseDestroyJson(_ json: [String: AnyObject]) {
        self.destroySound = soundFromJson(json)
    }
    
    fileprivate func parseHitJson(_ json: [String: AnyObject]) {
        self.hitSound = soundFromJson(json)        
        self.hitDamage = json["damage"] as? Int ?? 1
    }
    
    fileprivate func parseCheerJson(_ json: [String: AnyObject]) {
        self.cheerSound = soundFromJson(json)
    }

    fileprivate func parseSpawnJson(_ json: [String: AnyObject]) {
        self.spawnSound = soundFromJson(json)
    }
    
    fileprivate func parseCreatureJson(_ json: [String: AnyObject]) {
        if let livesJson = json["lives"] as? Int {
            self.lives = max(livesJson - 1, 0) // 3 lives => life 0, life 1, life 2
        }
        
        if let healthJson = json["health"] as? Int {
            self.health = max(healthJson, 0)
        }
        
        if let typeJson = json["type"] as? String {
            switch typeJson {
            case "monster": self.creatureType = .monster
            case "boss": self.creatureType = .boss
            default: self.creatureType = .undefined
            }
        }
    }
    
    fileprivate func parseSpriteJson(_ json: [String: AnyObject]) {
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
    
    fileprivate func parseAttackJson(_ json: [String: AnyObject]) {
        self.attackSound = soundFromJson(json)

        if let projectileJson = json["projectile"] as? String {
            self.projectile = projectileJson
        }
        
        if let directionJson = json["direction"] as? String {
            var attackDirection: AttackDirection
            
            switch directionJson {
            case "any": attackDirection = .radial
            case "axial": fallthrough
            default: attackDirection = .axial
            }
            
            self.attackDirection = attackDirection
        }
    }
    
    fileprivate func soundFromJson(_ json: [String: AnyObject]) -> String? {
        var sound: String?
        
        if let soundJson = json["sound"] as? String {
            sound = soundJson
        }
        
        return sound
    }

    // Returned a CountableRange before.
    fileprivate func animRangeFromJson(_ json: [String: AnyObject]) -> Range<Int> {
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
