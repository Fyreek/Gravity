//
//  HighscoreHelper.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 07/11/2016.
//  Copyright © 2016 YaLu. All rights reserved.
//

import Foundation

class HighscoreHelper {
    
    func getAchievements(curElapsedTime: TimeInterval) -> [Int] {
        
        let timeArr: [Int] = getScore(elapsedTime: curElapsedTime)
        
        let minutes = timeArr[0]
        let seconds = timeArr[1]
        
        if achievements.fiveSeconds == false {
            if seconds >= 5 {
                achievements.fiveSeconds = true
                GC.reportAchievement(progress: 100.00, achievementIdentifier: "gravity.achievement_5seconds", showBannnerIfCompleted: true, addToExisting: false)
                UserDefaults.standard.set(true, forKey: "fiveSeconds")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.fifthteenSeconds == false {
            if seconds >= 15 {
                achievements.fifthteenSeconds = true
                GC.reportAchievement(progress: 100.00, achievementIdentifier: "gravity.achievement_15seconds", showBannnerIfCompleted: true, addToExisting: false)
                UserDefaults.standard.set(true, forKey: "fifthteenSeconds")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.thirtySeconds == false {
            if seconds >= 30 {
                achievements.thirtySeconds = true
                GC.reportAchievement(progress: 100.00, achievementIdentifier: "gravity.achievement_30seconds", showBannnerIfCompleted: true, addToExisting: false)
                UserDefaults.standard.set(true, forKey: "thirtySeconds")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.sixtySeconds == false {
            if minutes >= 1 {
                achievements.sixtySeconds = true
                GC.reportAchievement(progress: 100.00, achievementIdentifier: "gravity.achievement_60seconds", showBannnerIfCompleted: true, addToExisting: false)
                UserDefaults.standard.set(true, forKey: "sixtySeconds")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.onehundredtwentySeconds == false {
            if minutes >= 2 {
                achievements.onehundredtwentySeconds = true
                GC.reportAchievement(progress: 100.00, achievementIdentifier: "gravity.achievement_120seconds", showBannnerIfCompleted: true, addToExisting: false)
                UserDefaults.standard.set(true, forKey: "onehundredtwentySeconds")
                UserDefaults.standard.synchronize()
            }
        }
        
        return timeArr
    }
    
    func getScore(elapsedTime: TimeInterval) -> [Int] {
        var timeLeft = elapsedTime
        let minutes = Int(timeLeft / 60.0)
        timeLeft -= TimeInterval(minutes) * 60
        let seconds = Int(timeLeft)
        timeLeft -= TimeInterval(seconds)
        let fraction = Int(round(timeLeft * 100.0)) % 100
        
        return [minutes, seconds, fraction]
    }
    
    func getScoreString(timeArr: [Int]) -> String {
        
        let strMinutes = String(format: "%02d", timeArr[0])
        let strSeconds = String(format: "%02d", timeArr[1])
        let strFraction = String(format: "%02d", timeArr[2])
        return "\(strMinutes):\(strSeconds).\(strFraction)"
    }
    
    func setHighscore() -> String {
        var highscoreTime:Double = 0
        if vars.extremeMode == false {
            highscoreTime = vars.highscore.roundToPlaces(2)
        } else {
            highscoreTime = vars.extHighscore.roundToPlaces(2)
        }
        
        let timeArr: [Int] = getScore(elapsedTime: highscoreTime)
        
        return getScoreString(timeArr: timeArr)
    }
}
