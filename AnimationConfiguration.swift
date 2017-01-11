//
//  AnimationConfiguration.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/06/16.
//
//

import Foundation

struct AnimationConfiguration {
    var duration: TimeInterval = 1.0
    var delay: TimeInterval = 0.0
    var repeatCount: Int = 1
    
    var centerAnimRange = 0 ..< 0
    var upAnimRange = 0 ..< 0
    var downAnimRange = 0 ..< 0
    var leftAnimRange = 0 ..< 0
    var rightAnimRange = 0 ..< 0

    init() {
    }
    
    init(json: [String: AnyObject]) {
        parseRangeFromJson(json)
        
        duration = durationFromJson(json)
        delay = delayFromJson(json) ?? 0.0
        repeatCount = repeatCountFromJson(json) ?? 1
    }
    
    // MARK: - Public
    
    func animRangeForDirection(_ direction: Direction) -> CountableRange<Int> {
        var animRange = 0 ..< 0
        
        switch direction {
        case .up: animRange = self.upAnimRange
        case .down: animRange = self.downAnimRange
        case .left: animRange = self.leftAnimRange
        case .right: animRange = self.rightAnimRange
        case .none: animRange = self.centerAnimRange
        }
        
        return animRange
    }
    
    // MARK: - Private
    
    fileprivate mutating func parseRangeFromJson(_ json: [String: AnyObject]) {
        if let rangeJson = json["range"] {
            switch rangeJson {
            case is NSArray:
                print("array: \(rangeJson)")
            case is NSDictionary:
                print("dict: \(rangeJson)")
            default: break
            }
        }
        
        if let rangeJson = json["range"] as? [Int] {
            let range = rangeFromJson(rangeJson)
            
            centerAnimRange = range
            upAnimRange = range
            leftAnimRange = range
            downAnimRange = range
            rightAnimRange = range
        } else if let rangeJson = json["range"] as? [String: AnyObject] {
            print("json: \(rangeJson)")
     
            if let rangeJson = rangeJson["center"] as? [Int] {
                centerAnimRange = rangeFromJson(rangeJson)
            }

            if let rangeJson = rangeJson["up"] as? [Int] {
                upAnimRange = rangeFromJson(rangeJson)
            }
            
            if let rangeJson = rangeJson["down"] as? [Int] {
                downAnimRange = rangeFromJson(rangeJson)
            }

            if let rangeJson = rangeJson["left"] as? [Int] {
                leftAnimRange = rangeFromJson(rangeJson)
            }
            
            if let rangeJson = rangeJson["right"] as? [Int] {
                rightAnimRange = rangeFromJson(rangeJson)
            }
        }
    }
    
    fileprivate func rangeFromJson(_ json: [Int]) -> CountableRange<Int> {
        var range = CountableRange<Int>(uncheckedBounds:(lower: 0, upper: 0))
        
        if json.count == 2 {
            let location = json[0]
            let length = json[1]
            range = CountableRange(location ..< (location + length))
        }
        
        return range
    }
    
    fileprivate func durationFromJson(_ json: [String: AnyObject]) -> TimeInterval {
        var duration: TimeInterval = 1.0
        
        if let durationJson = json["duration"] as? TimeInterval {
            duration = durationJson
        }
        
        return duration
    }
    
    fileprivate func repeatCountFromJson(_ json: [String: AnyObject]) -> Int? {
        var repeatCount: Int?
        
        if let repeatJson = json["repeat"] as? Int {
            repeatCount = repeatJson
        }
        
        return repeatCount
    }
    
    fileprivate func delayFromJson(_ json: [String: AnyObject]) -> TimeInterval? {
        var delay: TimeInterval?
        
        if let delayJson = json["delay"] as? TimeInterval {
            delay = delayJson
        }
        
        return delay
    }
}
