//
//  AssetManager.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 08/05/16.
//
//

import Foundation
import Zip

protocol AssetManagerDelegate: class {
    func assetManagerLoadAssetsSuccess(assetManager: AssetManager)
    func assetManagerLoadAssetsFailure(assetManager: AssetManager, error: ErrorType)
    func assetManagerLoadAssetsProgress(assetManager: AssetManager, progress: Float)
}

// TODO: The AssetManager should store / load Etags internally. The Etag methods should be private
//  to simplify the interface.

class AssetManager: NSObject, NSURLSessionDataDelegate {
    private let etagKey = "etag"
    
    private let fileManager = NSFileManager.defaultManager()
    private let userDefaults = NSUserDefaults.standardUserDefaults()

    private var buffer = NSMutableData()
    private var session: NSURLSession?
    private var dataTask: NSURLSessionDataTask?
    private var expectedContentLength = 0
    
    private let filename = "assets.zip"
    
    weak var delegate: AssetManagerDelegate?
    
    // MARK: - Public
    
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

        if let destinationDirectoryPath = fileManager.bundleSupportDirectoryPath() {
            let assetsDestinationPath = destinationDirectoryPath.stringByAppendingPathComponent(self.filename)
            if fileManager.fileExistsAtPath(assetsDestinationPath) {
                etag = userDefaults.valueForKey(etagKey) as? String
            }
       }

        return etag
    }
    
    func storeEtagForLocalAssetsArchive(etag: String?) {
        userDefaults.setValue(etag, forKey: etagKey)
        userDefaults.synchronize()
    }
    
    func loadAssets(assetsSourceURL: NSURL) {
        prepareForAssetsLoading()
        
        let identifier = "net.wolftrail.Bomberman.assetLoader"
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        let delegateQueue = NSOperationQueue.mainQueue()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        
        let dataTask = session.dataTaskWithURL(assetsSourceURL)
        dataTask.resume()
    }
    
    // MARK: - NSURLSessionDelegate
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        print("response received: \(response)")
        
        var responseDisposition = NSURLSessionResponseDisposition.Cancel
        
        if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
            self.expectedContentLength = Int(response.expectedContentLength)
            responseDisposition = NSURLSessionResponseDisposition.Allow
        }
        
        completionHandler(responseDisposition)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.buffer.appendData(data)
        
        let progress = Float(buffer.length) / Float(expectedContentLength)
        self.delegate?.assetManagerLoadAssetsProgress(self, progress: progress)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("completed task: \(task), error: \(error)")
        
        if error != nil {
            self.delegate?.assetManagerLoadAssetsFailure(self, error: error!)
        } else {
            // Create the bundle support directory path if needed.
            let destinationDirectoryPath = (fileManager.bundleSupportDirectoryPath())!
            
            // Create the destination download URL for the assets zip file.
            let assetsDestinationUrl = NSURL(fileURLWithPath: destinationDirectoryPath.stringByAppendingPathComponent(self.filename))
            
            do {
                try unzipAssets(fromData: self.buffer, assetsDestinationURL: assetsDestinationUrl)

                self.delegate?.assetManagerLoadAssetsSuccess(self)
            } catch let error {
                self.delegate?.assetManagerLoadAssetsFailure(self, error: error)
            }
        }
    }
    
    // MARK: - Private
    
    private func unzipAssets(fromData data: NSData, assetsDestinationURL: NSURL) throws {
        // Copy the zip file to the destnation path
        try data.writeToURL(assetsDestinationURL, options: .AtomicWrite)
        
        let destinationDirectoryUrl = (assetsDestinationURL.URLByDeletingLastPathComponent)!
        
        // Finally we can unzip the archive in the destination directory.
        try Zip.unzipFile(assetsDestinationURL, destination: destinationDirectoryUrl,
                          overwrite: true,
                          password: nil,
                          progress: { (progress) in
            print("progress: \(progress)")
        })
    }
    
    private func prepareForAssetsLoading() {
        self.buffer = NSMutableData()
        self.expectedContentLength = 0
    }
}