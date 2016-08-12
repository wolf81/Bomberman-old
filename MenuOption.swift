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
    case Checkbox
}

class MenuOption {
    private(set) var title: String
    private(set) var type: MenuOptionType
    private(set) var onSelected: (() -> Void)?
    
    var value: AnyObject?
    
    convenience init(title: String, onSelected: (() -> Void)? = nil) {
        self.init(title: title, type: .Default, value: nil, onSelected: onSelected)
    }
    
    init(title: String, type: MenuOptionType, value: AnyObject?, onSelected: (() -> Void)? = nil) {
        self.title = title
        self.type = type
        self.value = value
        self.onSelected = onSelected
    }
}