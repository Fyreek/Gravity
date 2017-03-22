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
    
    #if os(iOS)
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    #endif

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
        
        #if os(iOS)
        gameSettings = ["motioncontrol": "Motion Control" as AnyObject]
        gameSettings = ["extreme": "Extreme Mode" as AnyObject]
        UserDefaults.standard.register(defaults: gameSettings)
        vars.motionControl = UserDefaults.standard.bool(forKey: "motioncontrol")
        vars.extremeMode = UserDefaults.standard.bool(forKey: "extreme")
        #endif
            
        if vars.currentGameState == .gameActive && vars.extremeMode == true && vars.gameModeBefore == false {
            vars.gameScene?.goToMenu()
        } else if vars.currentGameState == .gameActive && vars.extremeMode == false && vars.gameModeBefore == true {
            vars.gameScene?.goToMenu()
        }
        
        #if os(iOS)
        if vars.motionControl == true{
            vars.gameScene?.initMotionControl()
        } else {
            vars.gameScene?.cancelMotionControl()
        }
        #endif
        
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
    
    #if os(iOS)
    @available(iOS 9.0, *)
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .motionControl:
                UserDefaults.standard.set(true, forKey: "motioncontrol")
                UserDefaults.standard.synchronize()
                vars.motionControl = true
                quickActionHandled = true
                
            case .touchControl:
                UserDefaults.standard.set(false, forKey: "motioncontrol")
                UserDefaults.standard.synchronize()
                vars.motionControl = false
                quickActionHandled = true
            }
        }
        return quickActionHandled
    }
    #endif
}

