//
//  Coin.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 17/08/16.
//
//

import SpriteKit

class Coin : Prop {
    override func destroy() {
        removePhysicsBody()
        
        super.destroy()
    }
}
