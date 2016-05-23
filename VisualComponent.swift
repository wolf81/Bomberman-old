//
//  VisualComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 23/04/16.
//
//

import GameplayKit
import SpriteKit

class VisualComponent: GKComponent {
    private(set) var sprites: [SKTexture]
    private(set) var spriteNode: SpriteNode
    
    init(sprites: [SKTexture]) {
        self.sprites = sprites
        
        var sprite: SpriteNode
        
        let size = CGSize(width: unitLength, height: unitLength)
        
        if let texture = sprites.first {
            sprite = SpriteNode(texture: texture, size: size)
            sprite.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.0, size: size)
        } else {
            sprite = SpriteNode(color: SKColor.redColor(), size: size)
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        }

        sprite.zPosition = 1
        
        self.spriteNode = sprite

        super.init()
    }
    
    func moveInDirection(direction: Direction, toPosition: CGPoint, completion: () -> Void) {
        if let configComponent = self.entity?.componentForClass(ConfigComponent) {
            var animRange = 0 ..< 0
            
            switch direction {
            case .East: animRange = configComponent.moveRightAnimRange
            case .North: animRange = configComponent.moveUpAnimRange
            case .West: animRange = configComponent.moveLeftAnimRange
            case .South: animRange = configComponent.moveDownAnimRange
            default: break
            }
                        
            var actions = [SKAction]()
            
            let duration: NSTimeInterval = 1.0
            
            let move = SKAction.moveTo(toPosition, duration: duration)
            actions.append(move)
            
            if animRange.endIndex > 0 {
                let textures = Array(self.sprites[animRange])
                let timePerFrame = duration / Double(textures.count)
                let animate = SKAction.animateWithTextures(textures, timePerFrame: timePerFrame)
                actions.append(animate)
            }
            
            let group = SKAction.group(actions)
            let sequence = SKAction.sequence([group, SKAction.runBlock(completion)])
            
            self.spriteNode.runAction(sequence, withKey: "move")
        }
    }    
}