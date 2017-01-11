//
//  VisualComponent.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 23/04/16.
//
//

import GameplayKit
import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class VisualComponent: GKComponent {
    fileprivate(set) var sprites: [SKTexture]
    fileprivate(set) var spriteNode: SpriteNode
    
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
            sprite = SpriteNode(color: SKColor.red, size: size)
            
            if createPhysicsBody {
                sprite.physicsBody = SKPhysicsBody(rectangleOf: size)
            }
        }
        
        sprite.zPosition = 1
        
        self.spriteNode = sprite

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func moveInDirection(_ direction: Direction, toPosition: CGPoint, completion: @escaping () -> Void) {
        if let entity = self.entity as? Entity,
            let configComponent = self.entity?.component(ofType: ConfigComponent.self) {
            
            let animRange = configComponent.moveAnimation.animRangeForDirection(entity.direction)
            
            var actions = [SKAction]()
            
            let duration: TimeInterval = 1.0
            
            let move = SKAction.move(to: toPosition, duration: duration)
            actions.append(move)
            
            if animRange.upperBound > 0 {
                let textures = Array(self.sprites[animRange])
                let timePerFrame = duration / Double(textures.count)
                let animate = SKAction.animate(with: textures, timePerFrame: timePerFrame)
                actions.append(animate)
            }
            
            let group = SKAction.group(actions)
            let sequence = SKAction.sequence([group, SKAction.run(completion)])            
            
            self.spriteNode.run(sequence, withKey: "move")
        }
    }    
}
