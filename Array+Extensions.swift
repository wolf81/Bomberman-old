//
//  Array+Extensions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 02/05/16.
//
//

import Foundation

extension Array where Element : Equatable {
    mutating func remove(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}
