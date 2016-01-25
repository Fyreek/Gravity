//
//  AppDelegate.swift
//  Gravity
//
//  Created by Luca Friedrich on 13/01/2016.
//  Copyright © 2016 YaLu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        // 3D Touch Start
        
        completionHandler(handleQuickAction(shortcutItem))
        
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        if vars.currentGameState == .gameActive {
            NSNotificationCenter.defaultCenter().postNotificationName("pauseGame", object: nil)
        }
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
        if vars.currentGameState == .gameActive {
            NSNotificationCenter.defaultCenter().postNotificationName("resumeGame", object: nil)
        }
        
        var gameSettings = Dictionary<String, AnyObject>()
        gameSettings["motioncontrol"] = false
        NSUserDefaults.standardUserDefaults().registerDefaults(gameSettings)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        vars.motionControl = NSUserDefaults.standardUserDefaults().boolForKey("motioncontrol")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    enum Shortcut: String {
        case motionControl = "MotionControl"
        case touchControl = "TouchControl"
    }
    
    @available(iOS 9.0, *)
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.componentsSeparatedByString(".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .motionControl:
                vars.motionControl = true
                quickActionHandled = true
            case .touchControl:
                vars.motionControl = false
                quickActionHandled = true
            }
        }
        
        return quickActionHandled
    }


}

