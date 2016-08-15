//
//  PowerUpLimit.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 05/06/16.
//
//

import Foundation

typealias OnValueChanged = () -> ()

struct PowerUpLimit {
    var currentCount: Int = 0
    let maxCount: Int
    
    init(currentCount: Int, maxCount: Int) {
        assert(currentCount <= maxCount, "currentCount max not be larger than maxCount")
        
        self.currentCount = currentCount
        self.maxCount = maxCount
    }
    
    mutating func increase(completion: OnValueChanged? = nil) {
        if currentCount < maxCount {
            currentCount += 1
            
            completion?()
        }
    }
    
    mutating func decrease(completion: OnValueChanged? = nil) {
        if currentCount > 0 {
            currentCount -= 1
            
            completion?()
        }
    }
}
