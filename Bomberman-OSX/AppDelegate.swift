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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let windowRect = self.windowRectWithSize(CGSize(width: 1280, height: 720))
        let styleMask: NSWindowStyleMask = [.resizable, .titled, .closable]

        NSApplication.shared().mainMenu = createMenu()
        
        self.window = NSWindow(contentRect: windowRect, styleMask: styleMask, backing: .buffered, defer: false)
        self.window.delegate = self
        self.window.minSize = windowRect.size
        
        self.gameViewController = GameViewController(nibName: nil, bundle: nil)
        self.window.contentView?.addSubview(self.gameViewController.view)
        self.window.makeKeyAndOrderFront(nil)
        
        // Game controller support.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(setupControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setupControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        GCController.startWirelessControllerDiscovery { 
            print("discovered controller ...")
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func windowRectWithSize(_ size: CGSize) -> CGRect {
        let screenSize = NSScreen.main()?.frame.size;
        let x = fmax((screenSize!.width - size.width) / 2, 0);
        let y = fmax((screenSize!.height - size.height) / 2, 0);
        return CGRect(x: x, y: y, width: size.width, height: size.height);
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        // TODO: pause game
        return frameSize
    }
    
    func windowDidResize(_ notification: Notification) {
        // TODO: unpause game
    }
    
    func createMenu() -> NSMenu {
        let menuBar = NSMenu()
        let appMenuItem = NSMenuItem()
        menuBar.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        let appName = ProcessInfo.processInfo.processName
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
    
    func quit(_ send: AnyObject?) {
        NSApplication.shared().terminate(nil)
    }
    
    // Game controller support.
    
    func setupControllers(_ notification: Notification) {
        self.controllers = GCController.controllers()
        
        print("controllers found: \(self.controllers)")

        if self.controllers.count > 0 {
            self.controllers.first?.playerIndex = .index1
            
            InputProxy.sharedInstance.configureController(self.controllers.first!, forPlayer: .index1)
                        
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
