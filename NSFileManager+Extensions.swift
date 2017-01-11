//
//  NSFileManager+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

extension FileManager {
    enum AppError: Error {
        case createBundleSupportDirectoryFailed
    }
    
    var cachesDirectoryPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = paths.first!
        return path
    }
    
    var applicationSupportDirectoryPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let path = paths.first!
        return path
    }
    
    func bundleSupportDirectoryPath(_ createIfNotExists: Bool = true) -> String? {
        var path: String?
        
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            path = cachesDirectoryPath.stringByAppendingPathComponent(bundleIdentifier)
            
            let fileManager = FileManager.default
            var isDirectory: ObjCBool = false
            let pathExists = fileManager.fileExists(atPath: path!, isDirectory: &isDirectory)
            
            if !pathExists && createIfNotExists {
                try! fileManager.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        return path
    }
    
    func pathForFile(_ file: String, inBundleSupportSubDirectory directory: String) throws -> String? {
        var path: String?
        
        path = try pathForBundleSupportSubDirectory(directory, createIfNotExists: true)
        path = path?.stringByAppendingPathComponent(file)
        
        return path
    }
    
    func pathForBundleSupportSubDirectory(_ directory: String, createIfNotExists: Bool) throws -> String? {
        var path: String?
        
        path = bundleSupportDirectoryPath()
        
        if path != nil {
            path = path!.stringByAppendingPathComponent(directory)
        }
        
        var isDirectory: ObjCBool = false
        if !fileExists(atPath: path!, isDirectory: &isDirectory) {
            try createDirectory(atPath: path!, withIntermediateDirectories: false, attributes: nil)
        }
        
        return path
    }
}
