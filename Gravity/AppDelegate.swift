//
//  AppDelegate.swift
//  Gravity
//
//  Created by Luca Friedrich on 13/01/2016.
//  Copyright © 2016 YaLu. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var gameSettings = Dictionary<String, AnyObject>()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }


    func applicationWillResignActive(application: UIApplication) {
        if vars.musicPlaying == true {
            GameViewController.MusicPause()
        }
        if vars.currentGameState == .gameActive {
            vars.gameScene?.stopTimerAfter()
            vars.gameModeBefore = vars.extremeMode
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        updateSoundState()
        
        if vars.currentGameState == .gameActive {
            vars.gameScene?.startTimerAfter()
        }
        
        gameSettings = ["motioncontrol": "Motion Control"]
        gameSettings = ["extreme": "Extreme Mode"]
        NSUserDefaults.standardUserDefaults().registerDefaults(gameSettings)
        vars.motionControl = NSUserDefaults.standardUserDefaults().boolForKey("motioncontrol")
        vars.extremeMode = NSUserDefaults.standardUserDefaults().boolForKey("extreme")
        
        if vars.currentGameState == .gameActive && vars.extremeMode == true && vars.gameModeBefore == false {
            vars.gameScene?.goToMenu()
        } else if vars.currentGameState == .gameActive && vars.extremeMode == false && vars.gameModeBefore == true {
            vars.gameScene?.goToMenu()
        }
        
        if vars.motionControl == true && vars.currentGameState == .gameActive {
            vars.gameScene?.initMotionControl()
        } else if vars.currentGameState == .gameActive {
            vars.gameScene?.cancelMotionControl()
        }
        if vars.extremeMode == true {
            vars.gameScene?.initExtremeMode()
        } else {
            vars.gameScene?.initNormalMode()
        }
    }

    func updateSoundState() {
        let hint = AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
        if hint == true {
            vars.musicState = false
        } else {
            vars.musicState =  true
        }
        if vars.musicState == true {
            GameViewController.MusicOff()
        } else {
            GameViewController.MusicOn()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
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
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "motioncontrol")
                NSUserDefaults.standardUserDefaults().synchronize()
                vars.motionControl = NSUserDefaults.standardUserDefaults().boolForKey("motioncontrol")
                quickActionHandled = true
                
            case .touchControl:
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "motioncontrol")
                NSUserDefaults.standardUserDefaults().synchronize()
                vars.motionControl = NSUserDefaults.standardUserDefaults().boolForKey("motioncontrol")
                quickActionHandled = true
            }
        }
        return quickActionHandled
    }
}

