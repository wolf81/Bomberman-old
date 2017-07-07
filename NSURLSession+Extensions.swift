//
//  NSURLSession+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 10/05/16.
//
//

import Foundation

extension URLSession {
    func synchronousDataTaskWithRequest(_ request: URLRequest) -> (Data?, URLResponse?, NSError?) {
        var data: Data?, response: URLResponse?, error: NSError?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        dataTask(with: request, completionHandler: {
            data = $0; response = $1; error = $2 as NSError?
            semaphore.signal()
            }) .resume()
        
        // TODO: handle success & timeout seperately ..?
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return (data, response, error)
    }
}
