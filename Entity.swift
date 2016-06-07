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
    func entityWillSpawn(entity: Entity)
    func entityDidSpawn(entity: Entity)
    func entityWillDestroy(entity: Entity)
    func entityDidDestroy(entity: Entity)
    func entityDidFloat(entity: Entity)
    func entityDidHit(entity: Entity)
    func entityDidAttack(entity: Entity)
    func entityDidCheer(entity: Entity)
    func entityDidDecay(entity: Entity)
}

class Entity: GKEntity {
    var gridPosition = Point(x: 0, y: 0)
    var value: PointsType?
    var spawnTimeAdjustment: NSTimeInterval = 0.0
    
    // The movement direction of the creature.
    var direction = Direction.None

    weak var game: Game?

    weak var delegate: EntityDelegate?
    
    var frame: CGRect {
        var frame = CGRectNull
        
        if let visualComponent = componentForClass(VisualComponent) {
            frame = visualComponent.spriteNode.frame
        }
        
        return frame
    }
    
    var canRoam: Bool {
        var canRoam = false
        
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            canRoam = stateMachineComponent.canRoam
        }
        
        return canRoam
    }
    
    var isDestroyed: Bool {
        var isDestroyed = false
        
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            isDestroyed = stateMachineComponent.currentState is DestroyState
        }

        return isDestroyed
    }

    var isControllable: Bool {
        var isControllable = false
        
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            isControllable = stateMachineComponent.currentState is ControlState
        }
        
        return isControllable
    }
    
    var isHit: Bool {
        var isHit = false
        
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
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
        if let basePath = configComponent.configFilePath {
            let filePath = basePath.stringByAppendingPathComponent(configComponent.textureFile)
            let imageData = NSData(contentsOfFile: filePath)
            let image = Image(data: imageData!)
            texture = SKTexture(image: image!)
        } else {
            texture = SKTexture(imageNamed: configComponent.textureFile)
        }
        
        let sprites = SpriteLoader.spritesFromTexture(texture, withSpriteSize: configComponent.spriteSize)
        let visualComponent = VisualComponent(sprites: sprites, createPhysicsBody: createPhysicsBody)
        visualComponent.spriteNode.speed = configComponent.speed
        addComponent(visualComponent)
        
        visualComponent.spriteNode.entity = self

        if let states = configComponent.states {
            let stateMachineComponent = StateMachineComponent(game: game, entity: self, states: states)
            addComponent(stateMachineComponent)
        }        
    }
    
    func destroy() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterDestroyState()
        }
    }
    
    func hit() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterHitState()
        }    
    }
    
    func propel() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterPropelState()
        }
    }
    
    func cheer() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterCheerState()
        }
    }
    
    func float() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterFloatState()
        }
    }
    
    func disintegrate() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterDisintegrateState()
        }
    }
    
    func spawn() {
        if let stateMachineComponent = self.componentForClass(StateMachineComponent) {
            stateMachineComponent.enterSpawnState()
        }
    }
    
    func control() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterControlState()
        }
    }
    
    func roam() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterRoamState()
        }
    }
        
    func attack() {
        if let stateMachineComponent = componentForClass(StateMachineComponent) {
            stateMachineComponent.enterAttackState()
        }
    }    
}
