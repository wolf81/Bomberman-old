//
//  AnimationConfiguration.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/06/16.
//
//

import Foundation

struct AnimationConfiguration {
    var spriteRange: Range<Int> = 0 ..< 0
    var duration: NSTimeInterval = 1.0
    var delay: NSTimeInterval = 0.0
    var repeatCount: Int = 1
}