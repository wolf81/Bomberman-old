//
//  NSFileManager+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

extension NSFileManager {
    enum AppError: ErrorType {
        case CreateBundleSupportDirectoryFailed
    }
    
    var documentsDirectoryPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = paths.first!
        return path
    }
    
    var applicationSupportDirectoryPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let path = paths.first!
        return path
    }
    
    func bundleSupportDirectoryPath(createIfNotExists: Bool = true) -> String? {
        var path: String?
        
        if let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier {
            path = applicationSupportDirectoryPath.stringByAppendingPathComponent(bundleIdentifier)
            
            let fileManager = NSFileManager.defaultManager()
            var isDirectory: ObjCBool = false
            let pathExists = fileManager.fileExistsAtPath(path!, isDirectory: &isDirectory)
            
            if !pathExists && createIfNotExists {
                try! fileManager.createDirectoryAtPath(path!, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        return path
    }
}
