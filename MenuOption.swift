//
//  MenuItem.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 10/08/16.
//
//

import Foundation

enum MenuOptionType {
    case Default
    case NumberChooser
    case Switch
}

class MenuOption {
    private(set) var title: String
    private(set) var type: MenuOptionType
    
    var value: AnyObject?
    
    convenience init(title: String) {
        self.init(title: title, type: .Default, value: nil)
    }
    
    init(title: String, type: MenuOptionType, value: AnyObject?) {
        self.title = title
        self.type = type
        self.value = value
    }
}