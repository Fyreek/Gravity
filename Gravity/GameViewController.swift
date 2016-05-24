//
//  GameViewController.swift
//  Gravity
//
//  Created by Luca Friedrich on 13/01/2016.
//  Copyright (c) 2016 YaLu. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import AVFoundation

class GameViewController: UIViewController, GCDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GC.sharedInstance(self)
        self.view.multipleTouchEnabled = true
        vars.gameScene = GameScene()
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        vars.gameScene!.scaleMode = .AspectFill
        vars.gameScene!.size = skView.bounds.size
        
        skView.presentScene(vars.gameScene)
        
        vars.gameScene!.viewController = self
    }
    
    func GCAuthentified(authentified:Bool) {
        if authentified {
            GC.getHighScore(leaderboardIdentifier: identifiers.iOSnormalLeaderboard) {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    vars.localPlayerName = tupleIsOk.playerName
                    var gcScore:Double = Double(tupleIsOk.score)
                    gcScore = gcScore / 100
                    if vars.highscore < gcScore {
                        
                        vars.highscore = gcScore
                            
                        NSUserDefaults.standardUserDefaults().setDouble(vars.highscore, forKey: "highscore")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                    } else {
                        GC.reportScoreLeaderboard(leaderboardIdentifier: identifiers.iOSnormalLeaderboard, score: Int(vars.highscore * 100))
                    }
                    vars.gameCenterLoggedIn = true
                }
            }
            GC.getHighScore(leaderboardIdentifier: identifiers.iOSextremeLeaderboard) {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    vars.localPlayerName = tupleIsOk.playerName
                    var gcExtScore:Double = Double(tupleIsOk.score)
                    gcExtScore = gcExtScore / 100
                    if vars.extHighscore < gcExtScore {
                        
                        vars.extHighscore = gcExtScore
                        
                        NSUserDefaults.standardUserDefaults().setDouble(vars.extHighscore, forKey: "extHighscore")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                    } else {
                        GC.reportScoreLeaderboard(leaderboardIdentifier: identifiers.iOSextremeLeaderboard, score: Int(vars.extHighscore * 100))
                    }
                    vars.gameCenterLoggedIn = true
                }
            }
            GC.getHighScore(leaderboardIdentifier: identifiers.iOStimesLeaderboard) {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    if vars.gamesPlayed < tupleIsOk.score {
                        
                        vars.gamesPlayed = tupleIsOk.score
                        
                        NSUserDefaults.standardUserDefaults().setInteger(vars.gamesPlayed, forKey: "gamesPlayed")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                    } else {
                        GC.reportScoreLeaderboard(leaderboardIdentifier: identifiers.iOStimesLeaderboard, score: vars.gamesPlayed)
                    }
                }
            }
        }
    }
    
    func activeMultiTouch() {
        self.view.multipleTouchEnabled = true
    }
    
    func deactivateMultiTouch() {
        self.view.multipleTouchEnabled = false
    }
    
    func getScores() {
        vars.highscorePlayerNames = []
        vars.highscorePlayerScore = []
        let leaderboardRequest: GKLeaderboard = GKLeaderboard()
        leaderboardRequest.playerScope = .FriendsOnly
        leaderboardRequest.timeScope = .AllTime
        leaderboardRequest.identifier = identifiers.iOSnormalLeaderboard
        leaderboardRequest.range = NSMakeRange(1, 5)
        leaderboardRequest.loadScoresWithCompletionHandler({(scores: [GKScore]?, error: NSError?) -> Void in
            if error != nil {
                print("error retrieving scores")
            }
            if scores != nil {
                if scores?.count > 1 {
                    for i in 0 ..< (scores?.count)! {
                        let player = scores![i].player.alias!
                        vars.highscorePlayerNames.append(String(player))
                        let score:String = String(scores![i].formattedValue!)
                        let newScore:String = score.substringFromIndex(score.startIndex.advancedBy(2))
                        vars.highscorePlayerScore.append(newScore)
                        vars.shouldOpenScoresList = false
                    }
                } else {
                    vars.shouldOpenScoresList = false
                }
                vars.gameScene?.openNewHighScore()
            }
        })
    }
    func getExtScores() {
        vars.highscorePlayerNames = []
        vars.highscorePlayerScore = []
        let leaderboardRequest: GKLeaderboard = GKLeaderboard()
        leaderboardRequest.playerScope = .FriendsOnly
        leaderboardRequest.timeScope = .AllTime
        leaderboardRequest.identifier = identifiers.iOSextremeLeaderboard
        leaderboardRequest.range = NSMakeRange(1, 5)
        leaderboardRequest.loadScoresWithCompletionHandler({(scores: [GKScore]?, error: NSError?) -> Void in
            if error != nil {
                print("error retrieving scores")
            }
            if scores != nil {
                if scores?.count > 1 {
                    for i in 0 ..< (scores?.count)! {
                        let player = scores![i].player.alias!
                        vars.highscorePlayerNames.append(String(player))
                        let score:String = String(scores![i].formattedValue!)
                        let newScore:String = score.substringFromIndex(score.startIndex.advancedBy(2))
                        vars.highscorePlayerScore.append(newScore)
                        vars.shouldOpenScoresList = true
                    }
                } else {
                    vars.shouldOpenScoresList = false
                }
                vars.gameScene?.openNewHighScore()
            }
        })
    }
    #if os(iOS)
    func shareHighscore() {
        let device = UIDevice.currentDevice().name

        let sharingText = "I've survived for " + ((NSString(format: "%.02f", vars.highscore)) as String) + " seconds in Gr4vity. Can you beat me?\nhttp://apple.co/1P2rkrT"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [sharingText], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        if device.containsString("iPhone") || device.containsString("iPod"){
            self.presentViewController(activityViewController, animated: true, completion: nil)
        } else if device.containsString("iPad") {
            let popup: UIPopoverController = UIPopoverController(contentViewController: activityViewController)
            popup.presentPopoverFromRect(CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 + 30, 0, 0), inView: self.view, permittedArrowDirections: .Up, animated: true)
        }
    }
    #endif
    
    #if os(iOS)
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation == .LandscapeLeft {
            vars.deviceOrientation = 3
        } else if UIDevice.currentDevice().orientation == .LandscapeRight {
            vars.deviceOrientation = 4
        }
    }
    #endif
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        do {
            
            vars.backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: url!)
        } catch {
            
        }
        if vars.backgroundMusicPlayer == nil {
            print("Could not create audio player!")
            return
        }
        if vars.musicState == true {
            vars.backgroundMusicPlayer.numberOfLoops = -1
            vars.backgroundMusicPlayer.prepareToPlay()
            vars.backgroundMusicPlayer.volume = 1
            vars.backgroundMusicPlayer.play()
        }
    }
    
    class func MusicPause() {
        if vars.musicPlaying == true && vars.backgroundMusicPlayer != nil {
            vars.backgroundMusicPlayer.pause()
        }
    }
    
    class func MusicOn() {
        let sess = AVAudioSession.sharedInstance()
        if sess.otherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient)
            _ = try? sess.setActive(true, withOptions: [])
        }
        if vars.musicPlaying == true {
            vars.musicPlaying = false
            vars.backgroundMusicPlayer.stop()
        }
    }
    
    class func MusicOff() {
        let sess = AVAudioSession.sharedInstance()
        if sess.otherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient)
            _ = try? sess.setActive(true, withOptions: [])
        }
        if vars.musicPlaying == false {
            vars.musicPlaying = true
            //playBackgroundMusic("music.caf")
        } else {
            if vars.backgroundMusicPlayer != nil {
                vars.backgroundMusicPlayer.play()
            }
        }
    }
    #if os(iOS)
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    #endif
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    #if os(iOS)
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    #endif
    
    #if os(tvOS)
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        for item in presses {
            if item.type == .Menu {
                if vars.currentGameState == .gameOver || vars.currentGameState == .gameActive {
                    vars.gameScene!.goToMenu()
                } else if vars.currentGameState == .gameMenu {
                    GC.showGameCenterLeaderboard(leaderboardIdentifier: "IdentifierLeaderboard")
                }
            } else if item.type == .PlayPause {
                if vars.currentGameState == .gameMenu {
                    vars.gameScene!.showGameLayer()
                } else if vars.currentGameState == .gameOver {
                    vars.gameScene!.restartButton()
                }
            } else if item.type == .RightArrow {
                if vars.currentGameState == .gameActive {
                    vars.gameScene?.moveLeft = false
                    vars.gameScene?.moveRight = true
                }
            } else if item.type == .LeftArrow {
                if vars.currentGameState == .gameActive {
                    vars.gameScene?.moveRight = false
                    vars.gameScene?.moveLeft = true
                }
            }
        }
    }

    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        for item in presses {
            if item.type == .Menu {
                if vars.currentGameState == .gameOver || vars.currentGameState == .gameActive {
                    vars.gameScene!.goToMenu()
                } else if vars.currentGameState == .gameMenu {
                    GC.showGameCenterLeaderboard(leaderboardIdentifier: "IdentifierLeaderboard")
                }
            } else if item.type == .PlayPause {
                if vars.currentGameState == .gameMenu {
                    vars.gameScene!.showGameLayer()
                } else if vars.currentGameState == .gameOver {
                    vars.gameScene!.restartButton()
                }
            } else if item.type == .RightArrow {
                if vars.currentGameState == .gameActive {
                    vars.gameScene?.moveRight = false
                }
            } else if item.type == .LeftArrow {
                if vars.currentGameState == .gameActive {
                    vars.gameScene?.moveLeft = false
                }
            }
        }
    }
    
    func swipedRight(gesture:UISwipeGestureRecognizer) {
        vars.gameScene?.tvOSMenuSwipeRight()
    }
    func swipedLeft(gesture:UISwipeGestureRecognizer) {
        vars.gameScene?.tvOSMenuSwipeLeft()
    }
    #endif
}