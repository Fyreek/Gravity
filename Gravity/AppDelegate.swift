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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }


    func applicationWillResignActive(_ application: UIApplication) {
        if vars.musicPlaying == true {
            GameViewController.MusicPause()
        }
        if vars.currentGameState == .gameActive {
            vars.gameScene?.stopTimerAfter()
            vars.gameModeBefore = vars.extremeMode
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        updateSoundState()
        
        if vars.currentGameState == .gameActive {
            vars.gameScene?.startTimerAfter()
        }
        
        gameSettings = ["motioncontrol": "Motion Control" as AnyObject]
        gameSettings = ["extreme": "Extreme Mode" as AnyObject]
        UserDefaults.standard.register(defaults: gameSettings)
        vars.motionControl = UserDefaults.standard.bool(forKey: "motioncontrol")
        vars.extremeMode = UserDefaults.standard.bool(forKey: "extreme")
        
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
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    @available(iOS 9.0, *)
    enum Shortcut: String {
        case motionControl = "MotionControl"
        case touchControl = "TouchControl"
    }
    
    @available(iOS 9.0, *)
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .motionControl:
                UserDefaults.standard.set(true, forKey: "motioncontrol")
                UserDefaults.standard.synchronize()
                vars.motionControl = UserDefaults.standard.bool(forKey: "motioncontrol")
                quickActionHandled = true
                
            case .touchControl:
                UserDefaults.standard.set(false, forKey: "motioncontrol")
                UserDefaults.standard.synchronize()
                vars.motionControl = UserDefaults.standard.bool(forKey: "motioncontrol")
                quickActionHandled = true
            }
        }
        return quickActionHandled
    }
}

