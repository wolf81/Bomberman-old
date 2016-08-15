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
    static let kAssetsCheckKey = "assetsCheck"
    static let kShowMenuOnStartupKey = "showMenuOnStartup"
    
    // MARK: - Private
    
    private static func setBool(flag: Bool, forKey key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(flag, forKey: key)
        userDefaults.synchronize()
    }
    
    private static func boolForKey(key: String) -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let flag = userDefaults.boolForKey(key)
        return flag
    }
    
    private static func setInteger(int: Int, forKey key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(int, forKey: key)
        userDefaults.synchronize()
    }
    
    private static func integerForKey(key: String) -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let int = userDefaults.integerForKey(key)
        return int
    }
    
    // MARK: - Public
    
    static func setInitialLevel(index: Int) {
        setInteger(index, forKey: kLevelKey)
    }
    
    static func initialLevel() -> Int {
        return integerForKey(kLevelKey)
    }
    
    static func setMusicEnabled(enabled: Bool) {
        setBool(enabled, forKey: kMusicKey)
    }
    
    static func musicEnabled() -> Bool {
        return boolForKey(kMusicKey)
    }
    
    static func setAssetsCheckEnabled(enabled: Bool) {
        setBool(enabled, forKey: kAssetsCheckKey)
    }
    
    static func assetsCheckEnabled() -> Bool {
        return boolForKey(kAssetsCheckKey)
    }
    
    static func setShowMenuOnStartupEnabled(enabled: Bool) {
        setBool(enabled, forKey: kShowMenuOnStartupKey)
    }
    
    static func showMenuOnStartupEnabled() -> Bool {
        return boolForKey(kShowMenuOnStartupKey)
    }
}