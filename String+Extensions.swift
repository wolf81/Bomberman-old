//
//  String+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 27/04/16.
//
//

import Foundation

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsString = self as NSString
        return nsString.stringByAppendingPathComponent(path)
    }
}