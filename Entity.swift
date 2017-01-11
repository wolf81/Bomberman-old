//
//  Entity.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import GameplayKit
import SpriteKit

protocol EntityDelegate: class {
    func entityWillSpawn(_ entity: Entity)
    func entityDidSpawn(_ entity: Entity)
    
    func entityWillDestroy(_ entity: Entity)
    func entityDidDestroy(_ entity: Entity)
    
    func entityDidAttack(_ entity: Entity)    
    func entityDidFloat(_ entity: Entity)
    func entityDidHit(_ entity: Entity)
    func entityDidCheer(_ entity: Entity)
    func entityDidDecay(_ entity: Entity)
}

class Entity: GKEntity {
    fileprivate (set) var uuid = UUID().uuidString
    
    var gridPosition = Point(x: 0, y: 0)
    var value: PointsType?
    var spawnTimeAdjustment: TimeInterval = 0.0
    
    // The movement direction of the creature.
    var direction = Direction.none

    weak var game: Game?

    weak var delegate: EntityDelegate?
    
    var frame: CGRect {
        var frame = CGRect.null
        
        if let visualComponent = component(ofType: VisualComponent.self) {
            frame = visualComponent.spriteNode.frame
        }
        
        return frame.integral
    }
    
    var speed: CGFloat {
        var speed: CGFloat = 1.0
        
        if let configComponent = component(ofType: ConfigComponent.self) {
            speed = configComponent.speed
        }
        
        return speed
    }
    
    var canRoam: Bool {
        var canRoam = false
        
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            canRoam = stateMachineComponent.canRoam
        }
        
        return canRoam
    }
    
    var canAttack: Bool {
        var canAttack = false
        
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            canAttack = stateMachineComponent.canAttack
        }
        
        return canAttack
    }
    
    var isDestroyed: Bool {
        var isDestroyed = false
        
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            isDestroyed = stateMachineComponent.currentState is DestroyState
        }

        return isDestroyed
    }

    var isControllable: Bool {
        var isControllable = false
        
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            isControllable = stateMachineComponent.currentState is ControlState
        }
        
        return isControllable
    }
    
    var isHit: Bool {
        var isHit = false
        
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            isHit = stateMachineComponent.currentState is HitState
        }
        
        return isHit
    }
    
    init(visualComponent: VisualComponent) {
        super.init()
        
        addComponent(visualComponent)
        
        visualComponent.spriteNode.entity = self
    }
    
    init(forGame game: Game,
                 configComponent: ConfigComponent,
                 gridPosition: Point = Point(x: 0, y: 0),
                 createPhysicsBody: Bool = true) {
        super.init()
        
        self.gridPosition = gridPosition
        self.game = game
        
        addComponent(configComponent)
        
        var texture: SKTexture
        
        // TODO: when game starts for first time, just copy files in bundle to assets directory
        //  and read from this location always. Or keep this code only for debug / devel purposes?
        let filePath = configComponent.configFilePath.stringByAppendingPathComponent(configComponent.textureFile)
        let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        let image = Image(data: imageData!)
        texture = SKTexture(image: image!)
        
        let sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: configComponent.spriteSize)
        let wu_size = configComponent.wuSize
        let visualComponent = VisualComponent(sprites: sprites, createPhysicsBody: createPhysicsBody, wu_size: wu_size)
        visualComponent.spriteNode.speed = configComponent.speed
        addComponent(visualComponent)
        
        visualComponent.spriteNode.entity = self

        if let states = configComponent.states {
            let stateMachineComponent = StateMachineComponent(game: game, entity: self, states: states)
            addComponent(stateMachineComponent)
        }        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removePhysicsBody() {
        if let visualComponent = component(ofType: VisualComponent.self) {
            visualComponent.spriteNode.physicsBody = nil
        }
    }
    
    func destroy() {
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterDestroyState()
        }
    }
    
    func hit(_ damage: Int = 1) {
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterHitState(damage)
        }    
    }
        
    func cheer() {
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterCheerState()
        }
    }
    
    func float() {
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterFloatState()
        }
    }
    
    func decay() {
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterDecayState()
        }
    }
    
    func spawn() {
        if let stateMachineComponent = self.component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterSpawnState()
        }
    }
    
    func control() {
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterControlState()
        }
    }
    
    func roam() {
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterRoamState()
        }
    }
        
    func attack() {
        if let stateMachineComponent = component(ofType: StateMachineComponent.self) {
            stateMachineComponent.enterAttackState()
        }
    }    
}
