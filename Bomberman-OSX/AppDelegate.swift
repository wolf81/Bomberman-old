//
//  AppDelegate.swift
//  Bomberman-OSX
//
//  Created by Wolfgang Schreurs on 22/04/16.
//


import Cocoa
import SpriteKit

import GameController

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    var gameViewController: GameViewController!
    
    var controllers: [GCController]!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let windowRect = self.windowRectWithSize(CGSize(width: 1280, height: 720))
        let styleMask = NSResizableWindowMask | NSTitledWindowMask | NSClosableWindowMask

        NSApplication.sharedApplication().mainMenu = createMenu()
        
        self.window = NSWindow(contentRect: windowRect, styleMask: styleMask, backing: .Buffered, defer: false)
        self.window.delegate = self
        self.window.minSize = windowRect.size
        
        self.gameViewController = GameViewController(nibName: nil, bundle: nil)
        self.window.contentView?.addSubview(self.gameViewController.view)
        self.window.makeKeyAndOrderFront(nil)
        
        // Game controller support.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(setupControllers), name: GCControllerDidConnectNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setupControllers), name: GCControllerDidDisconnectNotification, object: nil)
        GCController.startWirelessControllerDiscoveryWithCompletionHandler { 
            print("discovered controller ...")
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func windowRectWithSize(size: CGSize) -> CGRect {
        let screenSize = NSScreen.mainScreen()?.frame.size;
        let x = fmax((screenSize!.width - size.width) / 2, 0);
        let y = fmax((screenSize!.height - size.height) / 2, 0);
        return CGRect(x: x, y: y, width: size.width, height: size.height);
    }
    
    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        // TODO: pause game
        return frameSize
    }
    
    func windowDidResize(notification: NSNotification) {
        // TODO: unpause game
    }
    
    func createMenu() -> NSMenu {
        let menuBar = NSMenu()
        let appMenuItem = NSMenuItem()
        menuBar.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        let appName = NSProcessInfo.processInfo().processName
        let quitTitle = "Quit \(appName)"
        let quitMenuItem = NSMenuItem(
            title: quitTitle,
            action: #selector(quit),
            keyEquivalent: "q"
        )
        appMenu.addItem(quitMenuItem)
        appMenuItem.submenu = appMenu

        return menuBar
    }
    
    func quit(send: AnyObject?) {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // Game controller support.
    
    func setupControllers(notification: NSNotification) {
        self.controllers = GCController.controllers()
        
        print("controllers found: \(self.controllers)")

        if self.controllers.count > 0 {
            self.controllers.first?.playerIndex = .Index1
            
            InputProxy.sharedInstance.configureController(self.controllers.first!, forPlayer: .Index1)
                        
            // do something
            
            // when connected:
            // - move to controller based input
            // - remove on-screen virtual controls (e.g. pause button)
            // - set playerIndex to illuminate player indicator LEDs.
            
            // when disconnecting:
            // - pause gameplay
            // - return to regular controls
        }
    }
}
