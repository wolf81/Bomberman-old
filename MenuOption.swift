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

// TODO: Perhaps can use generics here. A simple implementation would default to number chooser for 
//  Int value type, checkbox for Bool value type, etcetera.

class MenuOption {
    private(set) var title: String
    private(set) var type = MenuOptionType.Default
    private(set) var onSelected: (() -> Void)?
    private(set) var onValueChanged: ((newValue: AnyObject?) -> Void)?
    
    var value: AnyObject? {
        didSet {
            if let onValueChanged = self.onValueChanged {
                onValueChanged(newValue: self.value)
            }
        }
    }
    
    // TODO: Figure out if we can use a cleaner solution than this assert. Static factory methods 
    //  for checkbox and number chooser could be one approach, but seems to not be idiomatic Swift.
    //  Another option could be using a builder class.
    init(title: String, type: MenuOptionType, value: AnyObject?, onValueChanged: ((newValue: AnyObject?) -> Void)? = nil) {
        assert(type != .Default, "Menu type of default can not have a value or value changed handler - use the other constructor.")
        
        self.title = title
        self.type = type
        self.value = value
        self.onValueChanged = onValueChanged
    }
    
    init(title: String, onSelected: (() -> Void)? = nil) {
        self.title = title
        self.onSelected = onSelected
    }
}