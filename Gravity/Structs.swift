//
//  Structs.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 13/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//

import SpriteKit
import AVFoundation

enum gameState {
    case gameMenu
    case gameOver
    case gameActive
}

struct vars {
    //If Value is at 0 look at the Function loadValues() in GameScene
    static var screenSize:CGSize = CGSize(width: 0, height: 0)
    static var barHeight:CGFloat = 0
    static var objectSize:CGFloat = 0
    static var screenOutLeft:CGFloat = 0
    static var screenOutRight:CGFloat = 0
    static var gravity:CGFloat = 0
    static var playerSideSpeed:CGFloat = 0
    static var gameLayerFadeTime:NSTimeInterval = 0.5 //AnimationTime - normal: 0.5
    static var objectWait:NSTimeInterval = 0.5 //How long a object waits before it moves - normal: 0.7
    static var timerWait:NSTimeInterval = 1 //How often an object spawns - normal: 0.7
    static var objectMoveTime:NSTimeInterval = 4 //How long it takes an object to reach the other side - normal: 3
    static var objectBorderWidth:CGFloat = 4 //How wide the border of an object is - normal: 4
    static var gameCenterLoggedIn:Bool = false //If the game is connected to GameCenter
    static var highscore:Double = 0 //Time Highscore
    static var extHighscore:Double = 0 //Extreme Time Highscore
    static var colorChangeTime:NSTimeInterval = 5 //How long it takes the game to switch between 2 colors - normal: 1
    static var currentGameState:gameState = .gameMenu //What state the game is in
    static var gamesPlayed:Int = 0 //Times played Highscore
    static var motionControl:Bool = false //If the game is controlled by motion control
    static var deviceOrientation:Int = 3 //Home button to the right
    static var firstTimePlaying:Bool = false //If the game is started the first time
    static var highscorePlayerNames:[String] = [] //Stores Friends Gamecenter names
    static var highscorePlayerScore:[String] = [] //Stores Friends Gamecenter scores
    static var localPlayerName:String = "" //Stores players Gamecenter name
    static var motionOrientation:String = "left"
    static var extremeMode:Bool = false //DIZ IS DE EXTREME MODE!!!!!
    static var showTutorial:Bool = false //If the Tutorial is shown. Do not change
    static var tutorialArrowAlpha:CGFloat = 1 //Alpha of the Tutorial arrows
    static var musicState:Bool = false //If the music should play or not
    static var musicPlaying:Bool = false //If music is playing
    static var gameScene = GameScene(fileNamed: "GameScene") //Gamescene reference
    static var backgroundMusicPlayer: AVAudioPlayer! //Player for the background music
    static var gameModeBefore:Bool = false
    static var selectedMenuItem:Int = 0 //Which Item is Selected in the Main Menu(0=Play; 1=GC)
    static var normalTextFrameHeight:CGFloat = 0 //Normal Height for the highscoreLabelTexts
    static var shouldOpenScoresList:Bool = false //If the games opens the own score list
    static var activeTouches:Int = 0 //Count of active touches
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

struct achievements {
    static var fiveSeconds:Bool = false
    static var fifthteenSeconds:Bool = false
    static var thirtySeconds:Bool = false
    static var sixtySeconds:Bool = false
    static var onehundredtwentySeconds:Bool = false
    static var pi:Bool = false
    static var newton:Bool = false
}

struct identifiers {
    static var iOSnormalLeaderboard:String = "gravity_leaderboard"
    static var iOStimesLeaderboard:String = "gravity_timesplayed"
    static var iOSextremeLeaderboard:String = "gravity_extreme"
    static var OSXnormalLeaderboard:String = "gravity_leaderboard_osx"
    static var OSXtimesLeaderboard:String = "gravity_timesplayed_osx"
}
