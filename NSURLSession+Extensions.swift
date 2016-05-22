//
//  NSURLSession+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 10/05/16.
//
//

import Foundation

extension NSURLSession {
    func synchronousDataTaskWithRequest(request: NSURLRequest) -> (NSData?, NSURLResponse?, NSError?) {
        var data: NSData?, response: NSURLResponse?, error: NSError?
        
        let semaphore = dispatch_semaphore_create(0)
        
        dataTaskWithRequest(request) {
            data = $0; response = $1; error = $2
            dispatch_semaphore_signal(semaphore)
            }.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return (data, response, error)
    }
}