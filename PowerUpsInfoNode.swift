//
//  AbilityInfoNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 04/06/16.
//
//

import SpriteKit

class PowerUpsInfoNode: SKShapeNode {
    private var powerUpNodes = [SKSpriteNode]()
    private var activePowers = Set<PowerType>()

    init(size: CGSize) {
        super.init()
                
        self.path = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: size), nil)
        
        self.antialiased = false
        self.lineWidth = 0
//        self.fillColor = SKColor.purpleColor()

        self.zPosition = 20
        
        updateAbilities()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updatePowers(power: PowerType, setActive isActive: Bool) {
        if isActive {
            self.activePowers.insert(power)
        } else {
            self.activePowers.remove(power)
        }
        
        updateAbilities()
    }
    
    func updateAbilities() {
        let powerUpSize = CGSize(width: 30, height: 30)
        
        let hudLoader = HudLoader()
        let powerUpSprites = hudLoader.powerUpSprites
        
        for i in (0 ..< 5).reverse() {
            var powerUpSprite: SKTexture

            let powerType = powerTypeForIndex(i)
            let isPowerActive = self.activePowers.contains(powerType)
            
            powerUpSprite = powerUpSprites[i + (isPowerActive ? 6 : 0)]

            let xPos = i * Int(powerUpSize.width) + 25
            let yPos = 45
            let powerUpNode = SKSpriteNode(texture: powerUpSprite, size: powerUpSize)
            powerUpNode.position = CGPoint(x: xPos, y: yPos)
            powerUpNode.anchorPoint = CGPointZero
            self.powerUpNodes.append(powerUpNode)
        }

        for powerUpNode in self.powerUpNodes {
            self.addChild(powerUpNode)
        }
    }
    
    private func powerTypeForIndex(index: Int) -> PowerType {
        var powerType: PowerType
        
        switch index {
        case 0: powerType = PowerType.BombAdd
        case 1: powerType = PowerType.BombSpeed
        case 2: powerType = PowerType.ExplosionSize
        case 3: powerType = PowerType.Shield
        default: powerType = PowerType.MoveSpeed
        }
//
        return powerType
    }
}