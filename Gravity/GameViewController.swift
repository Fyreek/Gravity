//
//  GameViewController.swift
//  Gravity
//
//  Created by Luca Friedrich on 13/01/2016.
//  Copyright (c) 2016 YaLu. All rights reserved.
//

import UIKit
import SpriteKit
import EasyGameCenter
import GameKit
import AVFoundation

class GameViewController: UIViewController, EGCDelegate {

    var backgroundMusicPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EGC.sharedInstance(self)
        self.view.multipleTouchEnabled = true
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.showsPhysics = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.size = skView.bounds.size
            
            skView.presentScene(scene)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "shareHighscore", name: "shareHighscore", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "getScores", name: "getScores", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "MusicOn", name: "MusicOn", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "MusicOff", name: "MusicOff", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "MusicPause", name: "MusicPause", object: nil)
            
        }
    }
    
    func EGCAuthentified(authentified:Bool) {
        if authentified {
            EGC.getHighScore(leaderboardIdentifier: "gravity_leaderboard") {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    vars.localPlayerName = tupleIsOk.playerName
                    if vars.highscore < Double(tupleIsOk.score) / 100 {
                        
                        vars.highscore = Double(tupleIsOk.score) / 100
                        vars.highscore = vars.highscore.roundToPlaces(2)
                            
                        NSUserDefaults.standardUserDefaults().setDouble(vars.highscore, forKey: "highscore")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                    } else {
                        EGC.reportScoreLeaderboard(leaderboardIdentifier: "gravity_leaderboard", score: Int(vars.highscore * 100))
                    }
                    vars.gameCenterLoggedIn = true
                }
            }
            EGC.getHighScore(leaderboardIdentifier: "gravity_timesplayed") {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    if vars.gamesPlayed < tupleIsOk.score {
                        
                        vars.gamesPlayed = tupleIsOk.score
                        
                        NSUserDefaults.standardUserDefaults().setInteger(vars.gamesPlayed, forKey: "gamesPlayed")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                    } else {
                        EGC.reportScoreLeaderboard(leaderboardIdentifier: "gravity_timesplayed", score: vars.gamesPlayed)
                    }
                }
            }
        }
    }
    
    func getScores() {
        vars.highscorePlayerNames = []
        vars.highscorePlayerScore = []
        let leaderboardRequest: GKLeaderboard = GKLeaderboard()
        leaderboardRequest.playerScope = .FriendsOnly
        leaderboardRequest.timeScope = .AllTime
        leaderboardRequest.identifier = "gravity_leaderboard"
        leaderboardRequest.range = NSMakeRange(1, 5)
        leaderboardRequest.loadScoresWithCompletionHandler({(scores: [GKScore]?, error: NSError?) -> Void in
            if error != nil {
                print("error retrieving scores")
            }
            if scores != nil {
                for var i = 0; i <= (scores?.count)! - 1; i++ {
                    let player = scores![i].player.alias!
                    vars.highscorePlayerNames.append(String(player))
                    let score:String = String(scores![i].formattedValue!)
                    let newScore:String = score.substringFromIndex(score.startIndex.advancedBy(2))
                    vars.highscorePlayerScore.append(newScore)
                }
                NSNotificationCenter.defaultCenter().postNotificationName("openNewHighScore", object: nil)
            }
        })
    }
    
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
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        do {
            
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: url!)
        } catch {
            
        }
        if backgroundMusicPlayer == nil {
            print("Could not create audio player!")
            return
        }
        if vars.musicState == true {
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.volume = 1
            backgroundMusicPlayer.play()
        }
    }
    
    func MusicPause() {
        if vars.musicPlaying == true {
            backgroundMusicPlayer.pause()
        }
    }
    
    func MusicOn() {
        let sess = AVAudioSession.sharedInstance()
        if sess.otherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient)
            _ = try? sess.setActive(true, withOptions: [])
        }
        if vars.musicPlaying == true {
            vars.musicPlaying = false
            backgroundMusicPlayer.stop()
        }
    }
    
    func MusicOff() {
        let sess = AVAudioSession.sharedInstance()
        if sess.otherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient)
            _ = try? sess.setActive(true, withOptions: [])
        }
        if vars.musicPlaying == false {
            vars.musicPlaying = true
            //playBackgroundMusic("music.caf")
        } else {
            backgroundMusicPlayer.play()
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}