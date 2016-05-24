//
//  AssetManager.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 08/05/16.
//
//

import Foundation
import Zip

enum AssetManagerError: ErrorType {
    case FailedToCreateBundleSupportDirectoryPath
}

class AssetManager: NSObject {
    static let sharedInstance = AssetManager()

    private let filename = "assets.zip"
    
    func etagForRemoteAssetsArchive(assetsSourceURL: NSURL) throws -> String? {
        var etag: String?
        
        let request = NSMutableURLRequest(URL: assetsSourceURL)
        request.HTTPMethod = "HEAD"

        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.timeoutIntervalForResource = 5
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let (data, response, error) = session.synchronousDataTaskWithRequest(request)
        print("response: \(response), data: \(data), error: \(error)")
            
        if let httpResponse = response as? NSHTTPURLResponse {
            etag = httpResponse.allHeaderFields["Etag"] as? String
        }
        
        return etag
    }
    
    func etagForLocalAssetsArchive() -> String? {
        var etag: String?

        let fileManager = NSFileManager.defaultManager()
        if let destinationDirectoryPath = fileManager.bundleSupportDirectoryPath() {
            let assetsDestinationPath = destinationDirectoryPath.stringByAppendingPathComponent(self.filename)
            if fileManager.fileExistsAtPath(assetsDestinationPath) {
                let defaults = NSUserDefaults.standardUserDefaults()
                etag = defaults.valueForKey("etag") as? String            
            }
       }

        return etag
    }
    
    func storeEtagForLocalAssetsArchive(etag: String?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(etag, forKey: "etag")
        defaults.synchronize()
    }
    
    func loadAssets(assetsSourceURL: NSURL, completion: (succes: Bool, error: NSError?) -> Void) throws {
        let fileManager = NSFileManager.defaultManager()
       
        // Create the bundle support directory path if needed.
        guard let destinationDirectoryPath = fileManager.bundleSupportDirectoryPath() else {
            throw AssetManagerError.FailedToCreateBundleSupportDirectoryPath
        }
        
        // Create the destination download URL for the assets zip file.
        let assetsDestinationURL = NSURL(fileURLWithPath: destinationDirectoryPath.stringByAppendingPathComponent(self.filename))

        let task = NSURLSession.sharedSession().dataTaskWithURL(assetsSourceURL) { (data, response, error) in
            guard
                let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200,
                let data = data where error == nil
                else { return }
            
            do {
                try data.writeToURL(assetsDestinationURL, options: .AtomicWrite)

                // Finally we can unzip the archive in the destination directory.
                let destinationDirectoryURL = NSURL(fileURLWithPath: destinationDirectoryPath)
                try Zip.unzipFile(assetsDestinationURL, destination: destinationDirectoryURL, overwrite: true, password: nil, progress: { (progress) in
                    print("progress: \(progress)")
                })
            } catch let error {
                print("error: \(error)")
            }
            
            completion(succes: true, error: nil)
        }
        task.resume()
    }
}