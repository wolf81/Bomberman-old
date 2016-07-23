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
    
    init(sprites: [SKTexture], createPhysicsBody: Bool = true, wu_size: Size = Size(width: 1, height: 1)) {
        self.sprites = sprites
        
        var sprite: SpriteNode
        
        let size = CGSize(width: unitLength * wu_size.width, height: unitLength * wu_size.height)
        
        if let texture = sprites.first {
            sprite = SpriteNode(texture: texture, size: size)
            
            if createPhysicsBody {
                // Create a body size slightly smaller than the actual texture, so we don't trigger 
                //  contact methods when 2 entities are beside each other.
                let bodySize = CGSize(width: size.width - 4, height: size.height - 4)

                sprite.physicsBody = SKPhysicsBody(texture: texture,
                                                   alphaThreshold: 0.0,
                                                   size: bodySize)
                
                // TODO: For images with a lot of alpha, the resulting physics body might be to small
                //  to notice contact. In that situation, create a custom body. Perhaps this should be
                //  done from config file instead.
                if sprite.physicsBody?.area < 0.1 {
                    sprite.physicsBody = SKPhysicsBody(circleOfRadius: 0.6)
                }
            }
        } else {
            sprite = SpriteNode(color: SKColor.redColor(), size: size)
            
            if createPhysicsBody {
                sprite.physicsBody = SKPhysicsBody(rectangleOfSize: size)
            }
        }
        
        sprite.zPosition = 1
        
        self.spriteNode = sprite

        super.init()
    }
        
    func moveInDirection(direction: Direction, toPosition: CGPoint, completion: () -> Void) {
        if let entity = self.entity as? Entity,
            let configComponent = self.entity?.componentForClass(ConfigComponent) {
            
            let animRange = configComponent.moveAnimation.animRangeForDirection(entity.direction)
            
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