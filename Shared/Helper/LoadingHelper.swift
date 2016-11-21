//
//  LoadingHelper.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 07/11/2016.
//  Copyright © 2016 YaLu. All rights reserved.
//

import Foundation
import SpriteKit

class LoadingHelper {

    func getSizes(curView: SKView) {
        vars.screenSize = (curView.frame.size) //What size the display has
        vars.barHeight = vars.screenSize.height / 6 //How high the bars at top and bottom are - normal: / 6
        vars.objectSize = vars.screenSize.height / 36 //How big the objects are - normal: / 36
        vars.screenOutLeft = -vars.objectSize * 2 //Spawnpoint on the left side
        vars.screenOutRight = vars.screenSize.width + vars.objectSize * 2 //Spawnpoint on the right side
    }
    
    func loadUserData() {
        if let _ = UserDefaults.standard.object(forKey: "highscore") {
            vars.highscore = UserDefaults.standard.double(forKey: "highscore")
        } else {
            vars.highscore = 0
        }
        if let _ = UserDefaults.standard.object(forKey: "extHighscore") {
            vars.extHighscore = UserDefaults.standard.double(forKey: "extHighscore")
        } else {
            vars.extHighscore = 0
        }
        if let _ = UserDefaults.standard.object(forKey: "extremeMode") {
            vars.extremeMode = UserDefaults.standard.bool(forKey: "extremeMode")
        } else {
            vars.extremeMode = false
        }
        if let _ = UserDefaults.standard.object(forKey: "firstTimePlaying") {
            vars.firstTimePlaying = UserDefaults.standard.bool(forKey: "firstTimePlaying")
        } else {
            vars.firstTimePlaying = false
        }
        if let _ = UserDefaults.standard.object(forKey: "gamesPlayed") {
            vars.gamesPlayed = UserDefaults.standard.integer(forKey: "gamesPlayed")
        } else {
            vars.gamesPlayed = 0
        }
        if let _ = UserDefaults.standard.object(forKey: "fiveSeconds") {
            achievements.fiveSeconds = UserDefaults.standard.bool(forKey: "fiveSeconds")
        } else {
            achievements.fiveSeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "fifthteenSeconds") {
            achievements.fifthteenSeconds = UserDefaults.standard.bool(forKey: "fifthteenSeconds")
        } else {
            achievements.fifthteenSeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "thirtySeconds") {
            achievements.thirtySeconds = UserDefaults.standard.bool(forKey: "thirtySeconds")
        } else {
            achievements.thirtySeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "sixytSeconds") {
            achievements.sixtySeconds = UserDefaults.standard.bool(forKey: "sixtySeconds")
        } else {
            achievements.sixtySeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "onehundredtwentySeconds") {
            achievements.onehundredtwentySeconds = UserDefaults.standard.bool(forKey: "onehundredtwentySeconds")
        } else {
            achievements.onehundredtwentySeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "pi") {
            achievements.pi = UserDefaults.standard.bool(forKey: "pi")
        } else {
            achievements.pi = false
        }
        if let _ = UserDefaults.standard.object(forKey: "newton") {
            achievements.newton = UserDefaults.standard.bool(forKey: "newton")
        } else {
            achievements.newton = false
        }
    }
    
}
