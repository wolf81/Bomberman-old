//
//  AppDelegate.swift
//  Bomberman-tvOS
//
//  Created by Wolfgang Schreurs on 22/04/16.
//
//

import UIKit
import GameController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var gameViewController: GameViewController!

    var controllers: [GCController]!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        self.gameViewController = GameViewController(nibName: nil, bundle: nil)

        window?.rootViewController = self.gameViewController
        window?.makeKeyAndVisible()
        
        // Game controller support.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(setupControllers), name: GCControllerDidConnectNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setupControllers), name: GCControllerDidDisconnectNotification, object: nil)
        GCController.startWirelessControllerDiscoveryWithCompletionHandler {
            print("discovered controller ...")
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Game controller support.
    
    func setupControllers(notification: NSNotification) {
        self.controllers = GCController.controllers()
        
        if self.controllers.count > 0 {
            self.controllers.first?.playerIndex = .Index1
            
            self.gameViewController.configureController(self.controllers.first!, forPlayer: .Index1)
            
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

