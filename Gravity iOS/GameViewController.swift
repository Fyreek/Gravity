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
        print(GC.sharedInstance(self))
        #if os(iOS)
        self.view.isMultipleTouchEnabled = true
        #endif
        vars.gameScene = GameScene()
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        vars.gameScene!.scaleMode = .aspectFill
        vars.gameScene!.size = skView.bounds.size
        
        skView.presentScene(vars.gameScene)
        
        vars.gameScene!.viewController = self
    }
    
    func GCAuthentified(_ authentified:Bool) {
        if authentified {
            vars.gameScene?.gamecenterLoggedIn()
            GC.getHighScore(leaderboardIdentifier: identifiers.iOSnormalLeaderboard) {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    vars.localPlayerName = tupleIsOk.playerName
                    var gcScore:Double = Double(tupleIsOk.score)
                    gcScore = gcScore / 100
                    if vars.highscore < gcScore {
                        
                        vars.highscore = gcScore
                            
                        UserDefaults.standard.set(vars.highscore, forKey: "highscore")
                        UserDefaults.standard.synchronize()
                        vars.gameScene!.menuLayer.highscoreNode.text = vars.gameScene!.scoreHelper.setHighscore()
                        
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
                        
                        UserDefaults.standard.set(vars.extHighscore, forKey: "extHighscore")
                        UserDefaults.standard.synchronize()
                        vars.gameScene!.menuLayer.highscoreNode.text = vars.gameScene!.scoreHelper.setHighscore()
                        
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
                        
                        UserDefaults.standard.set(vars.gamesPlayed, forKey: "gamesPlayed")
                        UserDefaults.standard.synchronize()
                        
                    } else {
                        GC.reportScoreLeaderboard(leaderboardIdentifier: identifiers.iOStimesLeaderboard, score: vars.gamesPlayed)
                    }
                }
            }
        } else {
            vars.gameScene?.gamecenterNotLoggedIn()
        }
    }
    
    #if os(iOS)
    func activeMultiTouch() {
        self.view.isMultipleTouchEnabled = true
    }
    
    func deactivateMultiTouch() {
        self.view.isMultipleTouchEnabled = false
    }
    #endif
    
    func getScores() {
        vars.highscorePlayerNames = []
        vars.highscorePlayerScore = []
        let leaderboardRequest: GKLeaderboard = GKLeaderboard()
        leaderboardRequest.playerScope = .friendsOnly
        leaderboardRequest.timeScope = .allTime
        leaderboardRequest.identifier = identifiers.iOSnormalLeaderboard
        leaderboardRequest.range = NSMakeRange(1, 5)
        leaderboardRequest.loadScores(completionHandler: {(scores: [GKScore]?, error: Error?) -> Void in
            if error != nil {
                print("error retrieving scores")
            }
            if scores != nil {
                if (scores?.count)! > 1 {
                    for i in 0 ..< (scores?.count)! {
                        let player = scores![i].player?.alias!
                        vars.highscorePlayerNames.append(String(describing: player))
                        let score:String = String(scores![i].formattedValue!)
                        let newScore:String = score.substring(from: score.characters.index(score.startIndex, offsetBy: 2))
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
        leaderboardRequest.playerScope = .friendsOnly
        leaderboardRequest.timeScope = .allTime
        leaderboardRequest.identifier = identifiers.iOSextremeLeaderboard
        leaderboardRequest.range = NSMakeRange(1, 5)
        leaderboardRequest.loadScores(completionHandler: {(scores: [GKScore]?, error: Error?) -> Void in
            if error != nil {
                print("error retrieving scores")
            }
            if scores != nil {
                if (scores?.count)! > 1 {
                    for i in 0 ..< (scores?.count)! {
                        let player = scores![i].player?.alias!
                        vars.highscorePlayerNames.append(String(describing: player))
                        let score:String = String(scores![i].formattedValue!)
                        let newScore:String = score.substring(from: score.characters.index(score.startIndex, offsetBy: 2))
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
        let device = UIDevice.current.name

        let sharingText = "I've survived for " + ((NSString(format: "%.02f", vars.highscore)) as String) + " seconds in Gr4vity. Can you beat me?\nhttp://apple.co/1P2rkrT"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [sharingText], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        if device.contains("iPhone") || device.contains("iPod"){
            self.present(activityViewController, animated: true, completion: nil)
        } else if device.contains("iPad") {
            let popup: UIPopoverController = UIPopoverController(contentViewController: activityViewController)
            popup.present(from: CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2 + 30, width: 0, height: 0), in: self.view, permittedArrowDirections: .up, animated: true)
        }
    }
    #endif
    
    #if os(iOS)
    override var shouldAutorotate : Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation == .landscapeLeft {
            vars.deviceOrientation = 3
        } else if UIDevice.current.orientation == .landscapeRight {
            vars.deviceOrientation = 4
        }
    }
    #endif
    
    class func playBackgroundMusic(_ filename: String) {
        let url = Bundle.main.url(
            forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        do {
            
            vars.backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url!)
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
        if sess.isOtherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient)
            _ = try? sess.setActive(true, with: [])
        }
        if vars.musicPlaying == true {
            vars.musicPlaying = false
            vars.backgroundMusicPlayer.stop()
        }
    }
    
    class func MusicOff() {
        let sess = AVAudioSession.sharedInstance()
        if sess.isOtherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient)
            _ = try? sess.setActive(true, with: [])
        }
        if vars.musicPlaying == false {
            vars.musicPlaying = true
            //playBackgroundMusic("music.caf")
            playBackgroundMusic("Gr4vity_wav.wav")
        } else {
            if vars.backgroundMusicPlayer != nil {
                vars.backgroundMusicPlayer.play()
            }
        }
    }
    #if os(iOS)
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    #endif
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    #if os(iOS)
    override var prefersStatusBarHidden : Bool {
        return true
    }
    #endif
    
    #if os(tvOS)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for item in presses {
            if item.type == .menu {
                super.pressesBegan(presses, with: event)
            } else if item.type == .rightArrow {
                if vars.currentGameState == .gameActive {
                    vars.gameScene?.moveLeft = false
                    vars.gameScene?.moveRight = true
                }
            } else if item.type == .leftArrow {
                if vars.currentGameState == .gameActive {
                    vars.gameScene?.moveRight = false
                    vars.gameScene?.moveLeft = true
                }
            }
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for item in presses {
            if item.type == .menu {
                super.pressesEnded(presses, with: event)
            } else if item.type == .playPause {
                if vars.currentGameState == .gameMenu {
                    if vars.extremeMode == false {
                        if vars.tvOSNotificationCooldown == false {
                            vars.tvOSNotificationCooldown = true
                            vars.extremeMode = true
                            vars.gameScene!.initExtremeMode()
                            GC.showCustomBanner(title: "Extreme Mode", description: "activated", duration: 0.5, completion: {
                                vars.tvOSNotificationCooldown = false
                            })
                        }
                    } else {
                        if vars.tvOSNotificationCooldown == false {
                            vars.tvOSNotificationCooldown = true
                            vars.extremeMode = false
                            vars.gameScene!.initNormalMode()
                            GC.showCustomBanner(title: "Normal Mode", description: "activated", duration: 0.5, completion: {
                                vars.tvOSNotificationCooldown = false
                            })
                        }
                    }
                } else {
                    vars.gameScene!.menuNodePressed()
                }
            } else if item.type == .rightArrow {
                if vars.currentGameState == .gameActive {
                    vars.gameScene?.moveRight = false
                }
            } else if item.type == .leftArrow {
                if vars.currentGameState == .gameActive {
                    vars.gameScene?.moveLeft = false
                }
            }
        }
    }
    
    func swipedRight(_ gesture:UISwipeGestureRecognizer) {
        vars.gameScene?.tvOSMenuSwipeRight()
    }
    func swipedLeft(_ gesture:UISwipeGestureRecognizer) {
        vars.gameScene?.tvOSMenuSwipeLeft()
    }
    #endif
}
