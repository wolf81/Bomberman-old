//
//  AbilityInfoNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class PowerUpsInfoNode: SKShapeNode {
    private let hudLoader = HudLoader()
    
    private var powerUpNodes = [SKSpriteNode]()
    private var activePowers = Set<PowerType>()

    // MARK: - Initilization
    
    init(size: CGSize) {
        super.init()
                
        self.path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)
        
        self.antialiased = false
        self.lineWidth = 0
        self.blendMode = .Replace
        
        updatePowerUpNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public
    
    func updatePower(power: PowerType, setActive isActive: Bool) {
        if isActive {
            self.activePowers.insert(power)
        } else {
            self.activePowers.remove(power)
        }
        
        updatePowerUpNodes()
    }
    
    // MARK: - Private
    
    private func updatePowerUpNodes() {
        self.removeAllChildren()
        self.powerUpNodes.removeAll()
        
        let spriteSize = CGSize(width: 30, height: 30)
        let sprites = self.hudLoader.powerUpSprites
        
        for i in (0 ..< 5).reverse() {
            var sprite: SKTexture

            let powerType = powerTypeForIndex(i)
            let isPowerActive = self.activePowers.contains(powerType)
            
            sprite = sprites[i + (isPowerActive ? 0 : 6)]

            let xPos = i * Int(spriteSize.width) + 25
            let yPos = 45
            let spriteNode = SKSpriteNode(texture: sprite, size: spriteSize)
            spriteNode.position = CGPoint(x: xPos, y: yPos)
            spriteNode.anchorPoint = CGPointZero
            self.powerUpNodes.append(spriteNode)
        }

        for powerUpNode in self.powerUpNodes {
            self.addChild(powerUpNode)
        }
    }
    
    private func powerTypeForIndex(index: Int) -> PowerType {
        var powerType: PowerType
        
        switch index {
        case 0: powerType = .BombAdd
        case 1: powerType = .BombSpeed
        case 2: powerType = .ExplosionSize
        case 3: powerType = .Shield
        case 4: powerType = .MoveSpeed
        default: powerType = .Unknown
        }
        
        return powerType
    }
}