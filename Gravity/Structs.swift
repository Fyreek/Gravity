//
//  Structs.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 13/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//

import SpriteKit

struct interScene {
    //If Value is at 0 look at the Function loadValues() in GameScene
    static var screenSize:CGSize = CGSize(width: 0, height: 0)
    static var barHeight:CGFloat = 0
    static var objectSize:CGFloat = 0
    static var screenOutLeft:CGFloat = 0
    static var screenOutRight:CGFloat = 0
    static var gameLayerFadeTime:NSTimeInterval = 0.5
    static var playerSideSpeed:CGFloat = 3
    static var gravity:CGFloat = 9.8
    static var objectWait:NSTimeInterval = 0.7
    static var timerWait:NSTimeInterval = 0.7
    static var objectMoveTime:NSTimeInterval = 3
    static var objectBorderWidth:CGFloat = 4
    static var objectFadeOutDuration:NSTimeInterval = 1
}
struct colors {
    static var playerColor:SKColor = SKColor.whiteColor()
    static var blueBarColor:SKColor = SKColor(red: 83 / 255, green: 88 / 255, blue: 128 / 255, alpha: 1)
    static var blueBGColor:SKColor = SKColor(red: 103 / 255, green: 108 / 255, blue: 148 / 255, alpha: 1)
    static var blueObjectColor:SKColor = SKColor(red: 103 / 255, green: 108 / 255, blue: 148 / 255, alpha: 1)
    static var blueObjectBorderColor:SKColor = SKColor(red: 83 / 255, green: 88 / 255, blue: 128 / 255, alpha: 1)
}
