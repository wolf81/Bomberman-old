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
    
    fileprivate static func setBool(_ flag: Bool, forKey key: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(flag, forKey: key)
        userDefaults.synchronize()
    }
    
    fileprivate static func boolForKey(_ key: String) -> Bool {
        let userDefaults = UserDefaults.standard
        let flag = userDefaults.bool(forKey: key)
        return flag
    }
    
    fileprivate static func setInteger(_ int: Int, forKey key: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(int, forKey: key)
        userDefaults.synchronize()
    }
    
    fileprivate static func integerForKey(_ key: String) -> Int {
        let userDefaults = UserDefaults.standard
        let int = userDefaults.integer(forKey: key)
        return int
    }
    
    // MARK: - Public
    
    static func setInitialLevel(_ index: Int) {
        setInteger(index, forKey: kLevelKey)
    }
    
    static func initialLevel() -> Int {
        return integerForKey(kLevelKey)
    }
    
    static func setMusicEnabled(_ enabled: Bool) {
        setBool(enabled, forKey: kMusicKey)
    }
    
    static func musicEnabled() -> Bool {
        return boolForKey(kMusicKey)
    }
    
    static func setAssetsCheckEnabled(_ enabled: Bool) {
        setBool(enabled, forKey: kAssetsCheckKey)
    }
    
    static func assetsCheckEnabled() -> Bool {
        return boolForKey(kAssetsCheckKey)
    }
    
    static func setShowMenuOnStartupEnabled(_ enabled: Bool) {
        setBool(enabled, forKey: kShowMenuOnStartupKey)
    }
    
    static func showMenuOnStartupEnabled() -> Bool {
        return boolForKey(kShowMenuOnStartupKey)
    }
}
