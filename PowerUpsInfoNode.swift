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
                
        path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)
        
        antialiased = false
        lineWidth = 0
        blendMode = .Replace
        
        updatePowerUpNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public
    
    func updatePower(power: PowerType, setActive isActive: Bool) {
        if isActive {
            activePowers.insert(power)
        } else {
            activePowers.remove(power)
        }
        
        updatePowerUpNodes()
    }
    
    // MARK: - Private
    
    private func updatePowerUpNodes() {
        removeAllChildren()
        powerUpNodes.removeAll()
        
        let spriteSize = CGSize(width: 30, height: 30)
        let sprites = hudLoader.powerUpSprites
        
        for i in (0 ..< 5).reverse() {
            var sprite: SKTexture

            let powerType = powerTypeForIndex(i)
            let isPowerActive = activePowers.contains(powerType)
            
            sprite = sprites[i + (isPowerActive ? 0 : 6)]

            let xPos = i * Int(spriteSize.width) + 25
            let yPos = 45
            let spriteNode = SKSpriteNode(texture: sprite, size: spriteSize)
            spriteNode.position = CGPoint(x: xPos, y: yPos)
            spriteNode.anchorPoint = CGPointZero
            powerUpNodes.append(spriteNode)
        }

        powerUpNodes.forEach { powerUpNode in addChild(powerUpNode) }
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