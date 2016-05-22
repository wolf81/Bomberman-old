//
//  main.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 22/04/16.
//
//

import Cocoa

let delegate = AppDelegate() //alloc main app's delegate class
NSApplication.sharedApplication().delegate = delegate //set as app's delegate

// Old versions:
// NSApplicationMain(C_ARGC, C_ARGV)
NSApplicationMain(Process.argc, Process.unsafeArgv);  //start of run loop