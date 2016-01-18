//
//  Structs.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 13/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//

import SpriteKit

struct vars {
    //If Value is at 0 look at the Function loadValues() in GameScene
    static var screenSize:CGSize = CGSize(width: 0, height: 0)
    static var barHeight:CGFloat = 0
    static var objectSize:CGFloat = 0
    static var screenOutLeft:CGFloat = 0
    static var screenOutRight:CGFloat = 0
    static var gameLayerFadeTime:NSTimeInterval = 0.5
    static var playerSideSpeed:CGFloat = 5
    static var gravity:CGFloat = 9.8
    static var objectWait:NSTimeInterval = 0.7
    static var timerWait:NSTimeInterval = 0.7
    static var objectMoveTime:NSTimeInterval = 3
    static var objectBorderWidth:CGFloat = 4
    static var objectFadeOutDuration:NSTimeInterval = 1
    static var gameCenterLoggedIn:Bool = false
    static var highScore:Int = 0
}
struct colors {
    static var playerColor:SKColor = SKColor.whiteColor()
    static var blueBGColor:SKColor = SKColor(red: 96 / 255, green: 201 / 255, blue: 248 / 255, alpha: 1)
    static var blueObjectColor:SKColor = SKColor(red: 66 / 255, green: 171 / 255, blue: 218 / 255, alpha: 1)
    static var yellowBGColor:SKColor = SKColor(red: 254 / 255, green: 203 / 255, blue: 47 / 255, alpha: 1)
    static var yellowObjectColor:SKColor = SKColor(red: 224 / 255, green: 173 / 255, blue: 17 / 255, alpha: 1)
    static var orangeBGColor:SKColor = SKColor(red: 253 / 255, green: 148 / 255, blue: 38 / 255, alpha: 1)
    static var orangeObjectColor:SKColor = SKColor(red: 223 / 255, green: 118 / 255, blue: 8 / 255, alpha: 1)
    static var redBGColor:SKColor = SKColor(red: 252 / 255, green: 49 / 255, blue: 89 / 255, alpha: 1)
    static var redObjectColor:SKColor = SKColor(red: 222 / 255, green: 19 / 255, blue: 59 / 255, alpha: 1)
    static var greenBGColor:SKColor = SKColor(red: 83 / 255, green: 215 / 255, blue: 105 / 255, alpha: 1)
    static var greenObjectColor:SKColor = SKColor(red: 53 / 255, green: 185 / 255, blue: 75 / 255, alpha: 1)
}
