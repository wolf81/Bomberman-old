//
//  Functions.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 25/05/16.
//
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}