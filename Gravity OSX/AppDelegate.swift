//
//  AppDelegate.swift
//  Gravity OSX
//
//  Created by Yannik Lauenstein on 04/04/16.
//  Copyright (c) 2016 YaLu. All rights reserved.
//


import Cocoa
import SpriteKit
import AVFoundation
import GameKit
import SystemConfiguration

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, GKGameCenterControllerDelegate, NSSharingServicePickerDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        window.delegate = self
        /* Pick a size for the scene */
        vars.gameScene = GameScene()
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        vars.gameScene!.scaleMode = .AspectFill
        vars.gameScene!.size = skView.bounds.size
        
        skView.presentScene(vars.gameScene)
        authenticateLocalPlayer()
    }
    
    func setWindowStyleGame() {
        window.styleMask = NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask
        let zoomButton: NSButton = window.standardWindowButton(NSWindowButton.ZoomButton)!
        zoomButton.hidden = true
    }
    
    func setWindowStyleMenu() {
        window.styleMask = NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
        let zoomButton: NSButton = window.standardWindowButton(NSWindowButton.ZoomButton)!
        zoomButton.hidden = false
    }
    
    func applicationWillResignActive(notification: NSNotification) {
       leaveActive()
    }
    
    func windowDidMiniaturize(notification: NSNotification) {
        leaveActive()
    }
    
    func windowDidDeminiaturize(notification: NSNotification) {
        returnActive()
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        returnActive()
    }
    
    func windowDidResize(notification: NSNotification) {
        vars.gameScene!.size = skView.bounds.size
        vars.gameScene!.rerangeInterface()
    }
    
    func updateSoundState() {
        if vars.musicState == true {
            MusicOff()
        } else {
            MusicOn()
        }
        NSUserDefaults.standardUserDefaults().setBool(vars.musicState, forKey: "musicState")
        
    }
    
    func returnActive() {
        
        updateSoundState()
        
        if vars.currentGameState == .gameActive {
            vars.gameScene?.startTimerAfter()
        }
        
        vars.extremeMode = NSUserDefaults.standardUserDefaults().boolForKey("extreme")
        
        if vars.currentGameState == .gameActive && vars.extremeMode == true && vars.gameModeBefore == false {
            vars.gameScene?.goToMenu()
        } else if vars.currentGameState == .gameActive && vars.extremeMode == false && vars.gameModeBefore == true {
            vars.gameScene?.goToMenu()
        }
        
        if vars.extremeMode == true {
            vars.gameScene?.initExtremeMode()
        } else {
            vars.gameScene?.initNormalMode()
        }

    }
    
    func leaveActive() {
        if vars.musicPlaying == true {
            MusicPause()
        }
        if vars.currentGameState == .gameActive {
            vars.gameScene?.stopTimerAfter()
            vars.gameModeBefore = vars.extremeMode
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
    
    func MusicPause() {
        if vars.musicPlaying == true && vars.backgroundMusicPlayer != nil {
            vars.backgroundMusicPlayer.pause()
        }
    }
    
    func MusicOn() {
        if vars.musicPlaying == true {
            vars.musicPlaying = false
            vars.backgroundMusicPlayer.stop()
        }
    }
    
    func MusicOff() {
        if vars.musicPlaying == false {
            vars.musicPlaying = true
            playBackgroundMusic("music.caf")
        } else {
            if vars.backgroundMusicPlayer != nil {
                vars.backgroundMusicPlayer.play()
            }
        }
    }
    
    func GCAuthentified(authentified:Bool) {
        if authentified {
            getHighScore(leaderboardIdentifier: identifiers.OSXnormalLeaderboard) {
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
                        self.reportScoreLeaderboard(identifiers.OSXnormalLeaderboard, score: Int(vars.highscore * 100))
                    }
                    vars.gameCenterLoggedIn = true
                    vars.gameScene?.achievementProgress()
                }
            }
            getHighScore(leaderboardIdentifier: identifiers.OSXtimesLeaderboard) {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    if vars.gamesPlayed < tupleIsOk.score {
                        
                        vars.gamesPlayed = tupleIsOk.score
                        
                        NSUserDefaults.standardUserDefaults().setInteger(vars.gamesPlayed, forKey: "gamesPlayed")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                    } else {
                        self.reportScoreLeaderboard(identifiers.OSXtimesLeaderboard, score: vars.gamesPlayed)
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
        leaderboardRequest.identifier = identifiers.OSXnormalLeaderboard
        leaderboardRequest.range = NSMakeRange(1, 5)
        leaderboardRequest.loadScoresWithCompletionHandler({(scores: [GKScore]?, error: NSError?) -> Void in
            if error != nil {
                print("error retrieving scores")
            }
            if scores != nil {
                if scores?.count > 1 {
                    for i in 0 ..< (scores?.count)! - 1 {
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
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func share() {
        let urls = ["I've survived for " + ((NSString(format: "%.02f", vars.highscore)) as String) + " seconds in Gr4vity for OSX. Can you beat me?\nhttp://apple.co/1P2rkrT"]
        let sharingServicePicker: NSSharingServicePicker = NSSharingServicePicker(items: urls)
        sharingServicePicker.delegate = self
        let position = vars.gameScene?.highscoreLayer.shareNode.frame.origin
        sharingServicePicker.showRelativeToRect(CGRect(x: position!.x, y: position!.y - 100, width: 100, height: 100), ofView: skView, preferredEdge: NSRectEdge.MinY)
    }
    
    //GameCenter
    
    var localPayer: GKLocalPlayer {
        get {
            return GKLocalPlayer.localPlayer()
        }
    }
    
    var isPlayerIdentified: Bool {
        get {
            return GKLocalPlayer.localPlayer().authenticated
        }
    }
    
    var isConnectedToNetwork: Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func reportScoreLeaderboard(leaderboardIdentifier: String, score: Int) {
        if isConnectedToNetwork && isPlayerIdentified {
            let gkScore = GKScore(leaderboardIdentifier: leaderboardIdentifier)
            gkScore.value = Int64(score)
            gkScore.shouldSetDefaultLeaderboard = true
            GKScore.reportScores([gkScore], withCompletionHandler: { (error: NSError?) in
                print("pushed score to GC!")
            })
        } else {
            print("Not Connected!")
        }
    }
    
    func getHighScore(
        leaderboardIdentifier leaderboardIdentifier:String,
                              completion:((playerName:String, score:Int,rank:Int)? -> Void)
        ) {
        getGKScoreLeaderboard(leaderboardIdentifier: leaderboardIdentifier, completion: {
            (resultGKScore) in

            guard let valGkscore = resultGKScore else {
                completion(nil)
                return
            }

            let rankVal = valGkscore.rank
            let nameVal  = self.localPayer.alias!
            let scoreVal  = Int(valGkscore.value)
            completion((playerName: nameVal, score: scoreVal, rank: rankVal))
            
        })
    }
    
    func  getGKScoreLeaderboard(leaderboardIdentifier leaderboardIdentifier:String, completion:((resultGKScore:GKScore?) -> Void)) {

        guard leaderboardIdentifier != "" else {
            //GCError.Empty.errorCall()
            completion(resultGKScore:nil)
            return
        }

        guard isConnectedToNetwork else {
            //GCError.NoConnection.errorCall()
            completion(resultGKScore: nil)
            return
        }

        guard isPlayerIdentified else {
            //GCError.NotLogin.errorCall()
            completion(resultGKScore: nil)
            return
        }

        let leaderBoardRequest = GKLeaderboard()
        leaderBoardRequest.identifier = leaderboardIdentifier

        leaderBoardRequest.loadScoresWithCompletionHandler {
            (resultGKScore, error) in

            guard error == nil && resultGKScore != nil else {
                completion(resultGKScore: nil)
                return
            }

            completion(resultGKScore: leaderBoardRequest.localPlayerScore)
            
        }
    }
    
    func reportAchievement( progress progress : Double, achievementIdentifier : String, showBannnerIfCompleted : Bool = true) {
        
        let achievement = GKAchievement(identifier: achievementIdentifier)
        achievement.percentComplete = progress
        achievement.showsCompletionBanner = showBannnerIfCompleted
        
        GKAchievement.reportAchievements([achievement], withCompletionHandler:  {
            (error:NSError?) -> Void in
            if error != nil {
                print("Error while pushing achievement: \(achievementIdentifier)")
            } else {
                print("Reported score for achievement: \(achievementIdentifier) with Progress of: \(achievement.percentComplete)")
            }
        })
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController: NSViewController?, error: NSError?) -> Void in
            if viewController != nil {
                //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
                //self.showAuthenticationDialogWhenReasonable(viewController)
            }
            else if localPlayer.authenticated {
                print("Logged in")
                self.GCAuthentified(localPlayer.authenticated)
            }
            else {
                print("Failed")
            }
        }
    }
    
    func showLeaderboard(leaderboardID: String) {
        if isConnectedToNetwork && isPlayerIdentified {
            let gameCenterController: GKGameCenterViewController = GKGameCenterViewController()
            gameCenterController.gameCenterDelegate = self
            gameCenterController.viewState = .Leaderboards
            gameCenterController.leaderboardTimeScope = .Today
            gameCenterController.leaderboardIdentifier = leaderboardID
            let sdc: GKDialogController = GKDialogController.sharedDialogController()
            sdc.parentWindow = window
            sdc.presentViewController(gameCenterController)
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        let sdc: GKDialogController = GKDialogController.sharedDialogController()
        sdc.dismiss(self)
    }
}
