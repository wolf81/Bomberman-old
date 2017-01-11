//
//  AbilityInfoNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class PowerUpsInfoNode: SKShapeNode {
    fileprivate let hudLoader = HudLoader()
    
    fileprivate var powerUpNodes = [SKSpriteNode]()
    fileprivate var activePowers = Set<PowerType>()

    // MARK: - Initilization
    
    init(size: CGSize) {
        super.init()
                
        path = CGPath(rect: CGRect(origin: CGPoint.zero, size: size), transform: nil)
        
        isAntialiased = false
        lineWidth = 0
        blendMode = .replace
        
        updatePowerUpNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public
    
    func updatePower(_ power: PowerType, setActive isActive: Bool) {
        if isActive {
            activePowers.insert(power)
        } else {
            activePowers.remove(power)
        }
        
        updatePowerUpNodes()
    }
    
    // MARK: - Private
    
    fileprivate func updatePowerUpNodes() {
        removeAllChildren()
        powerUpNodes.removeAll()
        
        let spriteSize = CGSize(width: 30, height: 30)
        let sprites = hudLoader.powerUpSprites
        
        for i in (0 ..< 5).reversed() {
            var sprite: SKTexture

            let powerType = powerTypeForIndex(i)
            let isPowerActive = activePowers.contains(powerType)
            
            sprite = sprites[i + (isPowerActive ? 0 : 6)]

            let xPos = i * Int(spriteSize.width) + 25
            let yPos = 45
            let spriteNode = SKSpriteNode(texture: sprite, size: spriteSize)
            spriteNode.position = CGPoint(x: xPos, y: yPos)
            spriteNode.anchorPoint = CGPoint.zero
            powerUpNodes.append(spriteNode)
        }

        powerUpNodes.forEach { powerUpNode in addChild(powerUpNode) }
    }
    
    fileprivate func powerTypeForIndex(_ index: Int) -> PowerType {
        var powerType: PowerType
        
        switch index {
        case 0: powerType = .bombAdd
        case 1: powerType = .bombSpeed
        case 2: powerType = .explosionSize
        case 3: powerType = .shield
        case 4: powerType = .moveSpeed
        default: powerType = .unknown
        }
        
        return powerType
    }
}
