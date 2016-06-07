//
//  AnimationConfiguration.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/06/16.
//
//

import Foundation

struct AnimationConfiguration {
    var duration: NSTimeInterval = 1.0
    var delay: NSTimeInterval = 0.0
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
        
        self.duration = durationFromJson(json)
        self.delay = delayFromJson(json) ?? 0.0
        self.repeatCount = repeatCountFromJson(json) ?? 1
    }
    
    // MARK: - Public
    
    func animRangeForDirection(direction: Direction) -> Range<Int> {
        var animRange = 0 ..< 0
        
        switch direction {
        case .North: animRange = self.upAnimRange
        case .South: animRange = self.downAnimRange
        case .West: animRange = self.leftAnimRange
        case .East: animRange = self.rightAnimRange
        case .None: animRange = self.centerAnimRange
        }
        
        return animRange
    }
    
    // MARK: - Private
    
    private mutating func parseRangeFromJson(json: [String: AnyObject]) {
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
            
            self.centerAnimRange = range
            self.upAnimRange = range
            self.leftAnimRange = range
            self.downAnimRange = range
            self.rightAnimRange = range
        } else if let rangeJson = json["range"] as? [String: AnyObject] {
            print("json: \(rangeJson)")
     
            if let rangeJson = rangeJson["center"] as? [Int] {
                self.centerAnimRange = rangeFromJson(rangeJson)
            }

            if let rangeJson = rangeJson["up"] as? [Int] {
                self.upAnimRange = rangeFromJson(rangeJson)
            }
            
            if let rangeJson = rangeJson["down"] as? [Int] {
                self.downAnimRange = rangeFromJson(rangeJson)
            }

            if let rangeJson = rangeJson["left"] as? [Int] {
                self.leftAnimRange = rangeFromJson(rangeJson)
            }
            
            if let rangeJson = rangeJson["right"] as? [Int] {
                self.rightAnimRange = rangeFromJson(rangeJson)
            }
        }
    }
    
    private func rangeFromJson(json: [Int]) -> Range<Int> {
        var range = 0 ..< 0
        
        if json.count == 2 {
            let location = json[0]
            let length = json[1]
            range = Range(location ..< (location + length))
        }
        
        return range
    }
    
    private func durationFromJson(json: [String: AnyObject]) -> NSTimeInterval {
        var duration: NSTimeInterval = 1.0
        
        if let durationJson = json["duration"] as? NSTimeInterval {
            duration = durationJson
        }
        
        return duration
    }
    
    private func repeatCountFromJson(json: [String: AnyObject]) -> Int? {
        var repeatCount: Int?
        
        if let repeatJson = json["repeat"] as? Int {
            repeatCount = repeatJson
        }
        
        return repeatCount
    }
    
    private func delayFromJson(json: [String: AnyObject]) -> NSTimeInterval? {
        var delay: NSTimeInterval?
        
        if let delayJson = json["delay"] as? NSTimeInterval {
            delay = delayJson
        }
        
        return delay
    }
}
