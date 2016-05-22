//
//  Array+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import Foundation

extension Array where Element : Equatable {
    mutating func remove(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}