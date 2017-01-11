//
//  MenuItem.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 10/08/16.
//
//

import Foundation

enum MenuOptionType {
    case `default`
    case numberChooser
    case checkbox
}

// TODO: Perhaps can use generics here. A simple implementation would default to number chooser for 
//  Int value type, checkbox for Bool value type, etcetera.

class MenuOption {
    fileprivate(set) var title: String
    fileprivate(set) var type = MenuOptionType.default
    fileprivate(set) var onSelected: (() -> Void)?
    fileprivate(set) var onValueChanged: ((_ newValue: AnyObject?) -> Void)?
    
    var onValidate: ((_ newValue: AnyObject?) -> Bool)?
    
    fileprivate(set) var value: AnyObject? {
        didSet {
            if let onValueChanged = self.onValueChanged {
                onValueChanged(value)
            }
        }
    }
    
    // TODO: Figure out if we can use a cleaner solution than this assert. Static factory methods 
    //  for checkbox and number chooser could be one approach, but seems to not be idiomatic Swift.
    //  Another option could be using a builder class.
    init(title: String, type: MenuOptionType, value: AnyObject?, onValueChanged: ((_ newValue: AnyObject?) -> Void)? = nil) {
        assert(type != .default, "Menu type of default can not have a value or value changed handler - use the other constructor.")
        
        self.title = title
        self.type = type
        self.value = value
        self.onValueChanged = onValueChanged
    }
    
    init(title: String, onSelected: (() -> Void)? = nil) {
        self.title = title
        self.onSelected = onSelected
    }
    
    // MARK: - Public 
    
    func update(_ newValue: AnyObject?) -> Bool {
        var didUpdate = false
     
        let updateBlock = {
            self.value = newValue
            didUpdate = true
        }

        if let onValidate = self.onValidate {
            if onValidate(newValue) {
                updateBlock()
            }
        } else {
            updateBlock()
        }
        
        return didUpdate
    }
}
