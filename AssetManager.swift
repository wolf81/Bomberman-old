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
    func assetManagerLoadAssetsSuccess(_ assetManager: AssetManager)
    func assetManagerLoadAssetsFailure(_ assetManager: AssetManager, error: Error)
    func assetManagerLoadAssetsProgress(_ assetManager: AssetManager, progress: Float)
}

// TODO: The AssetManager should store / load Etags internally. The Etag methods should be private
//  to simplify the interface.

class AssetManager: NSObject {
    fileprivate let etagKey = "etag"
    
    fileprivate let fileManager = FileManager.default
    fileprivate let userDefaults = UserDefaults.standard

    fileprivate var buffer = NSMutableData()
    fileprivate var session: Foundation.URLSession?
    fileprivate var dataTask: URLSessionDataTask?
    fileprivate var expectedContentLength = 0
    
    fileprivate let filename = "assets.zip"
    
    weak var delegate: AssetManagerDelegate?
    
    // MARK: - Public
    
    func etagForRemoteAssetsArchive(_ assetsSourceURL: URL) throws -> String? {
        var etag: String?
        
        let request = NSMutableURLRequest(url: assetsSourceURL)
        request.httpMethod = "HEAD"

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForResource = 5
        let session = Foundation.URLSession(configuration: sessionConfiguration)
        
        let (data, response, error) = session.synchronousDataTaskWithRequest(request as URLRequest)
        print("response: \(response), data: \(data), error: \(error)")
            
        if let httpResponse = response as? HTTPURLResponse {
            etag = httpResponse.allHeaderFields["Etag"] as? String
        }
        
        return etag
    }
    
    func etagForLocalAssetsArchive() -> String? {
        var etag: String?

        if let destinationDirectoryPath = fileManager.bundleSupportDirectoryPath() {
            let assetsDestinationPath = destinationDirectoryPath.stringByAppendingPathComponent(self.filename)
            if fileManager.fileExists(atPath: assetsDestinationPath) {
                etag = userDefaults.value(forKey: etagKey) as? String
            }
       }

        return etag
    }
    
    func storeEtagForLocalAssetsArchive(_ etag: String?) {
        userDefaults.setValue(etag, forKey: etagKey)
        userDefaults.synchronize()
    }
    
    func loadAssets(_ assetsSourceURL: URL) {
        prepareForAssetsLoading()
        
        let identifier = "net.wolftrail.Bomberman.assetLoader"
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        let delegateQueue = OperationQueue.main
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        
        let dataTask = session.dataTask(with: assetsSourceURL)
        dataTask.resume()
    }
    
    // MARK: - Private
    
    fileprivate func unzipAssets(fromData data: Data, assetsDestinationURL: URL) throws {
        // Copy the zip file to the destnation path
        try data.write(to: assetsDestinationURL, options: .atomicWrite)
        
        let destinationDirectoryUrl = (assetsDestinationURL.deletingLastPathComponent())
        
        // Finally we can unzip the archive in the destination directory.
        try Zip.unzipFile(assetsDestinationURL, destination: destinationDirectoryUrl,
                          overwrite: true,
                          password: nil,
                          progress: { (progress) in
            print("progress: \(progress)")
        })
    }
    
    fileprivate func prepareForAssetsLoading() {
        self.buffer = NSMutableData()
        self.expectedContentLength = 0
    }
}

// MARK: - NSURLSessionDataDelegate

extension AssetManager : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("response received: \(response)")
        
        var responseDisposition = Foundation.URLSession.ResponseDisposition.cancel
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            self.expectedContentLength = Int(response.expectedContentLength)
            responseDisposition = Foundation.URLSession.ResponseDisposition.allow
        }
        
        completionHandler(responseDisposition)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.buffer.append(data)
        
        let progress = Float(buffer.length) / Float(expectedContentLength)
        self.delegate?.assetManagerLoadAssetsProgress(self, progress: progress)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("completed task: \(task), error: \(error)")
        
        if error != nil {
            self.delegate?.assetManagerLoadAssetsFailure(self, error: error!)
        } else {
            // Create the bundle support directory path if needed.
            let destinationDirectoryPath = (fileManager.bundleSupportDirectoryPath())!
            
            // Create the destination download URL for the assets zip file.
            let assetsDestinationUrl = URL(fileURLWithPath: destinationDirectoryPath.stringByAppendingPathComponent(self.filename))
            
            do {
                try unzipAssets(fromData: self.buffer as Data, assetsDestinationURL: assetsDestinationUrl)
                
                self.delegate?.assetManagerLoadAssetsSuccess(self)
            } catch let error {
                self.delegate?.assetManagerLoadAssetsFailure(self, error: error)
            }
        }
    }
}
