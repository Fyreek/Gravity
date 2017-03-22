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
    @IBOutlet weak var soundMenuItem: NSMenuItem!
    @IBOutlet weak var modeMenuItem: NSMenuItem!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.delegate = self
        
        vars.gameScene = GameScene()
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = true
        
        vars.gameScene!.scaleMode = .aspectFill
        vars.gameScene!.size = skView.bounds.size
        
        skView.presentScene(vars.gameScene)
        authenticateLocalPlayer()
    }
    
    func setWindowStyleGame() {
        window.styleMask = [NSClosableWindowMask, NSTitledWindowMask, NSMiniaturizableWindowMask]
        let zoomButton: NSButton = window.standardWindowButton(NSWindowButton.zoomButton)!
        zoomButton.isHidden = true
    }
    
    func setWindowStyleMenu() {
        window.styleMask = [NSClosableWindowMask, NSTitledWindowMask, NSMiniaturizableWindowMask, NSResizableWindowMask]
        let zoomButton: NSButton = window.standardWindowButton(NSWindowButton.zoomButton)!
        zoomButton.isHidden = false
    }
    
    func setWindowStyleFullGame() {
        window.styleMask = [NSFullScreenWindowMask, NSClosableWindowMask]
        let zoomButton: NSButton = window.standardWindowButton(NSWindowButton.zoomButton)!
        zoomButton.isHidden = true
    }
    
    func setWindowStyleFullMenu() {
        window.styleMask = [NSFullScreenWindowMask, NSClosableWindowMask]
        let zoomButton: NSButton = window.standardWindowButton(NSWindowButton.zoomButton)!
        zoomButton.isHidden = false
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        vars.windowIsFullscreen = true
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        vars.windowIsFullscreen = false
        if vars.currentGameState == .gameMenu {
            setWindowStyleMenu()
        } else {
            setWindowStyleGame()
        }
    }
    
    @IBAction func soundMenuAction(_ sender: AnyObject) {
        musicUpdate()
        if vars.musicState == true {
            soundMenuItem.title = "Turn Sound Off"
        } else {
            soundMenuItem.title = "Turn Sound On"
        }
    }
    
    
    @IBAction func modeMenuAction(_ sender: AnyObject) {
        modeUpdate()
        if vars.extremeMode == true {
            modeMenuItem.title = "Normal Mode"
        } else {
            modeMenuItem.title = "Extreme Mode"
        }
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let musicSelector : Selector = #selector(self.musicUpdate)
        let modeSelector: Selector = #selector(self.modeUpdate)
        let musicItem = NSMenuItem()
        if vars.musicState == true {
            musicItem.title = "Turn Sound Off"
        } else {
            musicItem.title = "Turn Sound On"
        }
        musicItem.action = musicSelector
        musicItem.target = self
        let modeItem = NSMenuItem()
        if vars.extremeMode == true {
            modeItem.title = "Normal Mode"
        } else {
            modeItem.title = "Extreme Mode"
        }
        modeItem.action = modeSelector
        modeItem.target = self
        let gameMenu:NSMenu = NSMenu(title: "Func")
        gameMenu.autoenablesItems = true
        gameMenu.addItem(musicItem)
        gameMenu.addItem(modeItem)
        
        return gameMenu
    }
    
    func modeUpdate() {
        if vars.extremeMode == true {
            vars.extremeMode = false
            if vars.currentGameState == .gameActive || vars.currentGameState == .gameOver {
                vars.gameScene?.goToMenu()
            }
            updateModeState()
        } else {
            vars.extremeMode = true
            if vars.currentGameState == .gameActive || vars.currentGameState == .gameOver {
                vars.gameScene?.goToMenu()
            }
            updateModeState()
        }
    }
    
    func updateModeState() {
        if vars.extremeMode == true {
            vars.gameScene?.initExtremeMode()
        } else {
            vars.gameScene?.initNormalMode()
        }
        UserDefaults.standard.set(vars.extremeMode, forKey: "extreme")
    }
    
    func musicUpdate() {
        if vars.currentGameState == .gameMenu {
            if vars.musicState == true {
                vars.musicState = false
            } else {
                vars.musicState = true
            }
            updateSoundState()
        }
    }
    
    func applicationWillResignActive(_ notification: Notification) {
       leaveActive()
    }
    
    func windowDidMiniaturize(_ notification: Notification) {
        leaveActive()
    }
    
    func windowDidDeminiaturize(_ notification: Notification) {
        returnActive()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        returnActive()
    }
    
    func windowDidResize(_ notification: Notification) {
        vars.gameScene!.size = skView.bounds.size
        vars.gameScene!.rerangeInterface()
    }
    
    func updateSoundState() {
        if vars.musicState == true {
            MusicOff()
        } else {
            MusicOn()
        }
        UserDefaults.standard.set(vars.musicState, forKey: "musicState")
        
    }
    
    func returnActive() {
        
        updateSoundState()
        
        if vars.currentGameState == .gameActive {
            vars.gameScene?.startTimerAfter()
        }
        
        vars.extremeMode = UserDefaults.standard.bool(forKey: "extreme")
        
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
    
    func playBackgroundMusic(_ filename: String) {
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
            playBackgroundMusic("Gr4vity_wav.wav")
        } else {
            if vars.backgroundMusicPlayer != nil {
                vars.backgroundMusicPlayer.play()
            }
        }
    }
    
    func GCAuthentified(_ authentified:Bool) {
        if authentified {
            getHighScore(identifiers.OSXnormalLeaderboard) {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    vars.localPlayerName = tupleIsOk.playerName
                    var gcScore:Double = Double(tupleIsOk.score)
                    gcScore = gcScore / 100
                    if vars.highscore < gcScore {
                        
                        vars.highscore = gcScore
                        
                        UserDefaults.standard.set(vars.highscore, forKey: "highscore")
                        UserDefaults.standard.synchronize()
                        
                    } else {
                        self.reportScoreLeaderboard(identifiers.OSXnormalLeaderboard, score: Int(vars.highscore * 100))
                    }
                    //vars.gameCenterLoggedIn = true
                    vars.gameScene?.achievementProgress()
                }
            }
            getHighScore(identifiers.OSXtimesLeaderboard) {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    if vars.gamesPlayed < tupleIsOk.score {
                        
                        vars.gamesPlayed = tupleIsOk.score
                        
                        UserDefaults.standard.set(vars.gamesPlayed, forKey: "gamesPlayed")
                        UserDefaults.standard.synchronize()
                        
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
        leaderboardRequest.playerScope = .friendsOnly
        leaderboardRequest.timeScope = .allTime
        leaderboardRequest.identifier = identifiers.OSXnormalLeaderboard
        leaderboardRequest.range = NSMakeRange(1, 5)
        leaderboardRequest.loadScores(completionHandler: { (scores: [GKScore]?, error) -> Void in
        //}
        //leaderboardRequest.loadScoresWithCompletionHandler({(scores: [GKScore]?, error: NSError?) -> Void in
            if error != nil {
                print("error retrieving scores")
            }
            if scores != nil {
                if (scores?.count)! > 1 {
                    for i in 0 ..< (scores?.count)! {
                        let player = scores![i].player?.alias!
                        vars.highscorePlayerNames.append(String(describing: player))
                        let score:String = String(scores![i].formattedValue!)
                        //let newScore:String = score.substringFromIndex(score.startIndex.advancedBy(2))
                        //let newScore:String = score.substring(from: score.startIndex.advancedBy(2))
                        //let newScore:String = score.substring(from: score[2])
                        
                        let subIndex = score.index(score.startIndex, offsetBy: 2)
                        let newScore:String = score.substring(from: subIndex)
                        
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
    
    func getExtScores() {
        vars.highscorePlayerNames = []
        vars.highscorePlayerScore = []
        let leaderboardRequest: GKLeaderboard = GKLeaderboard()
        leaderboardRequest.playerScope = .friendsOnly
        leaderboardRequest.timeScope = .allTime
        leaderboardRequest.identifier = identifiers.OSXextremeLeaderboard
        leaderboardRequest.range = NSMakeRange(1, 5)
        leaderboardRequest.loadScores(completionHandler: { (scores: [GKScore]?, error) -> Void in
            if error != nil {
                print("error retrieving scores")
            }
            if scores != nil {
                if (scores?.count)! > 1 {
                    for i in 0 ..< (scores?.count)! {
                        let player = scores![i].player?.alias!
                        vars.highscorePlayerNames.append(String(describing: player))
                        let score:String = String(scores![i].formattedValue!)
                        let subIndex = score.index(score.startIndex, offsetBy: 2)
                        let newScore:String = score.substring(from: subIndex)
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
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func share() {
        let urls = ["I've survived for " + ((NSString(format: "%.02f", vars.highscore)) as String) + " seconds in Gr4vity for OSX. Can you beat me?\nhttp://apple.co/1P2rkrT"]
        let sharingServicePicker: NSSharingServicePicker = NSSharingServicePicker(items: urls)
        sharingServicePicker.delegate = self
        let position = vars.gameScene?.highscoreLayer.shareNode.frame.origin
        sharingServicePicker.show(relativeTo: CGRect(x: position!.x, y: position!.y - 100, width: 100, height: 100), of: skView, preferredEdge: NSRectEdge.minY)
    }
    
    //GameCenter
    
    var localPayer: GKLocalPlayer {
        get {
            return GKLocalPlayer.localPlayer()
        }
    }
    
    var isPlayerIdentified: Bool {
        get {
            return GKLocalPlayer.localPlayer().isAuthenticated
        }
    }
    
    var isConnectedToNetwork: Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                zeroSockAddress in SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func reportScoreLeaderboard(_ leaderboardIdentifier: String, score: Int) {
        if isConnectedToNetwork && isPlayerIdentified {
            let gkScore = GKScore(leaderboardIdentifier: leaderboardIdentifier)
            gkScore.value = Int64(score)
            gkScore.shouldSetDefaultLeaderboard = true
            GKScore.report([gkScore], withCompletionHandler: { (error: Error?) in
                print("pushed score to GC!")
            })
            //GKScore.reportScores([gkScore], withCompletionHandler: { (error: NSError?) in
            //    print("pushed score to GC!")
            //})
        } else {
            print("Not Connected!")
        }
    }
    
    func getHighScore(
        _ leaderboardIdentifier:String,
                              completion:@escaping (((playerName:String, score:Int,rank:Int)?) -> Void)
        ) {
        getGKScoreLeaderboard(leaderboardIdentifier, completion: {
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
    
    func  getGKScoreLeaderboard(_ leaderboardIdentifier:String, completion:@escaping ((_ resultGKScore:GKScore?) -> Void)) {

        guard leaderboardIdentifier != "" else {
            completion(nil)
            return
        }

        guard isConnectedToNetwork else {
            completion(nil)
            return
        }

        guard isPlayerIdentified else {
            completion(nil)
            return
        }

        let leaderBoardRequest = GKLeaderboard()
        leaderBoardRequest.identifier = leaderboardIdentifier

        leaderBoardRequest.loadScores {
            (resultGKScore, error) in

            guard error == nil && resultGKScore != nil else {
                completion(nil)
                return
            }

            completion(leaderBoardRequest.localPlayerScore)
            
        }
    }
    
    func reportAchievement( _ progress : Double, achievementIdentifier : String, showBannnerIfCompleted : Bool = true) {
        
        let achievement = GKAchievement(identifier: achievementIdentifier)
        achievement.percentComplete = progress
        achievement.showsCompletionBanner = showBannnerIfCompleted
        
        GKAchievement.report([achievement], withCompletionHandler: {
            (error:Error?) -> Void in
            if error != nil {
                print("Error while pushing achievement: \(achievementIdentifier)")
            } else {
                print("Reported score for achievement: \(achievementIdentifier) with Progress of: \(achievement.percentComplete)")
            }
        })
        
    }
    
    func authenticateLocalPlayer() {
        print("Login start")
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController: NSViewController?, error: Error?) -> Void in
            if localPlayer.isAuthenticated {
                print("Logged in")
                self.GCAuthentified(localPlayer.isAuthenticated)
                vars.gameScene?.gamecenterLoggedIn()
                vars.gameCenterLoggedIn = true
            } else {
                print("Unable to login")
                vars.gameScene?.gamecenterNotLoggedIn()
                vars.gameCenterLoggedIn = false
            }
            print(error)
        }
    }
    
    func showLeaderboard(_ leaderboardID: String) {
        print("Connected: " + String(isConnectedToNetwork))
        print("identified: " + String(isConnectedToNetwork))
        if isConnectedToNetwork && isPlayerIdentified {
            let gameCenterController: GKGameCenterViewController = GKGameCenterViewController()
            gameCenterController.gameCenterDelegate = self
            gameCenterController.viewState = .leaderboards
            gameCenterController.leaderboardTimeScope = .today
            gameCenterController.leaderboardIdentifier = leaderboardID
            let sdc: GKDialogController = GKDialogController.shared()
            sdc.parentWindow = window
            sdc.present(gameCenterController)
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        let sdc: GKDialogController = GKDialogController.shared()
        sdc.dismiss(self)
    }
}
