//
//  main.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 22/04/16.
//
//

import Cocoa

let delegate = AppDelegate() //alloc main app's delegate class
NSApplication.shared().delegate = delegate //set as app's delegate

// Old versions:
// NSApplicationMain(C_ARGC, C_ARGV)
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv);  //start of run loop
