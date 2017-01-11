//
//  Focusable.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 11/08/16.
//
//

import Foundation

protocol Focusable {
    func setFocused(_ focused: Bool)
    func isFocused() -> Bool
}
