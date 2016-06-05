//
//  PowerUpLimit.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 05/06/16.
//
//

import Foundation

struct PowerUpLimit {
    var currentCount: Int = 0
    let maxCount: Int
    
    init(currentCount: Int, maxCount: Int) {
        assert(currentCount <= maxCount, "currentCount max not be larger than maxCount")
        
        self.currentCount = currentCount
        self.maxCount = maxCount
    }
}
