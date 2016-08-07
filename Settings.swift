//
//  Settings.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 07/08/16.
//
//

import Foundation

class Settings {
    static let kLevelKey = "level"
    static let kMusicKey = "music"
    
    static func setInitialLevel(index: Int) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(index, forKey: kLevelKey)
        userDefaults.synchronize()
    }
    
    static func initialLevel() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let level = userDefaults.integerForKey(kLevelKey)
        return level
    }
    
    static func setMusicEnabled(enabled: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(enabled, forKey: kMusicKey)
        userDefaults.synchronize()
    }
    
    static func musicEnabled() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let enabled = userDefaults.boolForKey(kMusicKey)
        return enabled
    }
}