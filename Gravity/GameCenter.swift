//
//  GameCenter.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 22/03/16.
//  Copyright © 2016 YaLu. All rights reserved.
//

import Foundation
import GameKit
import SystemConfiguration

@objc public protocol GCDelegate:NSObjectProtocol {

    optional func GCAuthentified(authentified:Bool)

    optional func GCInCache()

    optional func GCMatchStarted()

    optional func GCMatchRecept(match: GKMatch, didReceiveData: NSData, fromPlayer: String)

    optional func GCMatchEnded()

    optional func GCMatchCancel()
}

extension GC {

    static var isConnectedToNetwork: Bool {
        
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
}

public class GC: NSObject, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate, GKLocalPlayerListener {

    private var achievementsCache:[String:GKAchievement] = [String:GKAchievement]()
    private var achievementsDescriptionCache = [String:GKAchievementDescription]()
    private var achievementsCacheShowAfter = [String:String]()
    private var timerNetAndPlayer:NSTimer?
    private var debugModeGetSet:Bool = false
    static var showLoginPage:Bool = true
    private var match: GKMatch?
    private var playersInMatch = Set<GKPlayer>()
    public var invitedPlayer: GKPlayer?
    public var invite: GKInvite?
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GC.authenticationChanged), name: GKPlayerAuthenticationDidChangeNotificationName, object: nil)
    }

    struct Static {
        static var onceToken: dispatch_once_t = 0
        static var instance: GC? = nil
        static weak var delegate: UIViewController? = nil
    }
    
    public class func sharedInstance(delegate:UIViewController)-> GC {
        if Static.instance == nil {
            dispatch_once(&Static.onceToken) {
                Static.instance = GC()
                Static.delegate = delegate
                Static.instance!.loginPlayerToGameCenter()
            }
        }
        return Static.instance!
    }

    class var delegate: UIViewController {
        get {
            do {
                let delegateInstance = try GC.sharedInstance.getDelegate()
                return delegateInstance
            } catch  {
                GCError.NoDelegate.errorCall()
                fatalError("Dont work\(error)")
            }
        }
        
        set {
            guard newValue != GC.delegate else {
                return
            }
            Static.delegate = GC.delegate
            
            //Log commented, because of error!
            //EGC.printLogEGC("New delegate UIViewController is \(_stdlib_getDemangledTypeName(newValue))\n")
        }
    }

    public class var debugMode:Bool {
        get {
            return GC.sharedInstance.debugModeGetSet
        }
        set {
            GC.sharedInstance.debugModeGetSet = newValue
        }
    }

    public static var isPlayerIdentified: Bool {
        get {
            return GKLocalPlayer.localPlayer().authenticated
        }
    }
    
    static var localPayer: GKLocalPlayer {
        get {
            return GKLocalPlayer.localPlayer()
        }
    }
    
    class func getlocalPlayerInformation(completion completionTuple: (playerInformationTuple:(playerID:String,alias:String,profilPhoto:UIImage?)?) -> ()) {
        
        guard GC.isConnectedToNetwork else {
            completionTuple(playerInformationTuple: nil)
            GCError.NoConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            completionTuple(playerInformationTuple: nil)
            GCError.NotLogin.errorCall()
            return
        }
        
        GC.localPayer.loadPhotoForSize(GKPhotoSizeNormal, withCompletionHandler: {
            (image, error) in
            
            var playerInformationTuple:(playerID:String,alias:String,profilPhoto:UIImage?)
            playerInformationTuple.profilPhoto = nil
            
            playerInformationTuple.playerID = GC.localPayer.playerID!
            playerInformationTuple.alias = GC.localPayer.alias!
            if error == nil { playerInformationTuple.profilPhoto = image }
            completionTuple(playerInformationTuple: playerInformationTuple)
        })
    }
    
    public class func showGameCenter(completion: ((isShow:Bool) -> Void)? = nil) {
        
        guard GC.isConnectedToNetwork else {
            if completion != nil { completion!(isShow:false) }
            GCError.NoConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            if completion != nil { completion!(isShow:false) }
            GCError.NotLogin.errorCall()
            return
        }
        
        
        GC.printLogGC("Show Game Center")
        
        let gc                = GKGameCenterViewController()
        gc.gameCenterDelegate = Static.instance
        
        #if !os(tvOS)
            gc.viewState          = GKGameCenterViewControllerState.Default
        #endif
        
        var delegeteParent:UIViewController? = GC.delegate.parentViewController
        if delegeteParent == nil {
            delegeteParent = GC.delegate
        }
        delegeteParent!.presentViewController(gc, animated: true, completion: {
            if completion != nil { completion!(isShow:true) }
        })
        
    }
    
    public class func showGameCenterAchievements(completion: ((isShow:Bool) -> Void)? = nil) {
        
        guard GC.isConnectedToNetwork else {
            if completion != nil { completion!(isShow:false) }
            GCError.NoConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            if completion != nil { completion!(isShow:false) }
            GCError.NotLogin.errorCall()
            return
        }
        
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = Static.instance
        #if !os(tvOS)
            gc.viewState = GKGameCenterViewControllerState.Achievements
        #endif
        
        var delegeteParent:UIViewController? = GC.delegate.parentViewController
        if delegeteParent == nil {
            delegeteParent = GC.delegate
        }
        delegeteParent!.presentViewController(gc, animated: true, completion: {
            if completion != nil { completion!(isShow:true) }
        })
    }
    
    public class func showGameCenterLeaderboard(leaderboardIdentifier leaderboardIdentifier :String, completion: ((isShow:Bool) -> Void)? = nil) {
        
        guard leaderboardIdentifier != "" else {
            GCError.Empty.errorCall()
            if completion != nil { completion!(isShow:false) }
            return
        }
        
        guard GC.isConnectedToNetwork else {
            GCError.NoConnection.errorCall()
            if completion != nil { completion!(isShow:false) }
            return
        }
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            if completion != nil { completion!(isShow:false) }
            return
        }
        
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = Static.instance
        #if !os(tvOS)
            gc.leaderboardIdentifier = leaderboardIdentifier
            gc.viewState = GKGameCenterViewControllerState.Leaderboards
        #endif
        
        var delegeteParent:UIViewController? = GC.delegate.parentViewController
        if delegeteParent == nil {
            delegeteParent = GC.delegate
        }
        delegeteParent!.presentViewController(gc, animated: true, completion: {
            if completion != nil { completion!(isShow:true) }
        })
        
    }

    public class func showGameCenterChallenges(completion: ((isShow:Bool) -> Void)? = nil) {
        
        guard GC.isConnectedToNetwork else {
            if completion != nil { completion!(isShow:false) }
            GCError.NoConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            if completion != nil { completion!(isShow:false) }
            GCError.NotLogin.errorCall()
            return
        }
        
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate =  Static.instance
        #if !os(tvOS)
            gc.viewState = GKGameCenterViewControllerState.Challenges
        #endif
        
        var delegeteParent:UIViewController? =  GC.delegate.parentViewController
        if delegeteParent == nil {
            delegeteParent =  GC.delegate
        }
        delegeteParent!.presentViewController(gc, animated: true, completion: {
            () -> Void in
            
            if completion != nil { completion!(isShow:true) }
        })
        
    }
    
    public class func showCustomBanner(title title:String, description:String,completion: (() -> Void)? = nil) {
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return
        }
        
        GKNotificationBanner.showBannerWithTitle(title, message: description, completionHandler: completion)
    }
    
    public class func showGameCenterAuthentication(completion: ((result:Bool) -> Void)? = nil) {
        if completion != nil {
            completion!(result: UIApplication.sharedApplication().openURL(NSURL(string: "gamecenter:")!))
        }
    }
    
    public class func getGKLeaderboard(completion completion: ((resultArrayGKLeaderboard:Set<GKLeaderboard>?) -> Void)) {
        
        guard GC.isConnectedToNetwork else {
            completion(resultArrayGKLeaderboard: nil)
            GCError.NoConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            completion(resultArrayGKLeaderboard: nil)
            GCError.NotLogin.errorCall()
            return
        }
        
        GKLeaderboard.loadLeaderboardsWithCompletionHandler {
            (leaderboards, error) in
            
            guard GC.isPlayerIdentified else {
                completion(resultArrayGKLeaderboard: nil)
                GCError.NotLogin.errorCall()
                return
            }
            
            guard let leaderboardsIsArrayGKLeaderboard = leaderboards as [GKLeaderboard]? else {
                completion(resultArrayGKLeaderboard: nil)
                GCError.Error(error?.localizedDescription).errorCall()
                return
            }
            
            completion(resultArrayGKLeaderboard: Set(leaderboardsIsArrayGKLeaderboard))
            
        }
    }
    
    public class func reportScoreLeaderboard(leaderboardIdentifier leaderboardIdentifier:String, score: Int) {
        guard GC.isConnectedToNetwork else {
            GCError.NoConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return
        }
        
        let gkScore = GKScore(leaderboardIdentifier: leaderboardIdentifier)
        gkScore.value = Int64(score)
        gkScore.shouldSetDefaultLeaderboard = true
        GKScore.reportScores([gkScore], withCompletionHandler: nil)
    }
    
    public class func getHighScore(
        leaderboardIdentifier leaderboardIdentifier:String,
                              completion:((playerName:String, score:Int,rank:Int)? -> Void)
        ) {
        GC.getGKScoreLeaderboard(leaderboardIdentifier: leaderboardIdentifier, completion: {
            (resultGKScore) in
            
            guard let valGkscore = resultGKScore else {
                completion(nil)
                return
            }
            
            let rankVal = valGkscore.rank
            let nameVal  = GC.localPayer.alias!
            let scoreVal  = Int(valGkscore.value)
            completion((playerName: nameVal, score: scoreVal, rank: rankVal))
            
        })
    }
    
    public class func  getGKScoreLeaderboard(leaderboardIdentifier leaderboardIdentifier:String, completion:((resultGKScore:GKScore?) -> Void)) {
        
        guard leaderboardIdentifier != "" else {
            GCError.Empty.errorCall()
            completion(resultGKScore:nil)
            return
        }
        
        guard GC.isConnectedToNetwork else {
            GCError.NoConnection.errorCall()
            completion(resultGKScore: nil)
            return
        }
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
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

    public class func getTupleGKAchievementAndDescription(achievementIdentifier achievementIdentifier:String,completion completionTuple: ((tupleGKAchievementAndDescription:(gkAchievement:GKAchievement,gkAchievementDescription:GKAchievementDescription)?) -> Void)) {
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            completionTuple(tupleGKAchievementAndDescription: nil)
            return
        }
        
        let achievementGKScore = GC.sharedInstance.achievementsCache[achievementIdentifier]
        let achievementGKDes =  GC.sharedInstance.achievementsDescriptionCache[achievementIdentifier]
        
        guard let aGKS = achievementGKScore, let aGKD = achievementGKDes else {
            completionTuple(tupleGKAchievementAndDescription: nil)
            return
        }
        
        completionTuple(tupleGKAchievementAndDescription: (aGKS,aGKD))
        
    }
    
    public class func getAchievementForIndentifier(identifierAchievement identifierAchievement : NSString) -> GKAchievement? {
        
        guard identifierAchievement != "" else {
            GCError.Empty.errorCall()
            return nil
        }
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return nil
        }
        
        guard let achievementFind = GC.sharedInstance.achievementsCache[identifierAchievement as String] else {
            return nil
        }
        return achievementFind
    }
    
    public class func reportAchievement( progress progress : Double, achievementIdentifier : String, showBannnerIfCompleted : Bool = true ,addToExisting: Bool = false) {
        
        guard achievementIdentifier != "" else {
            GCError.Empty.errorCall()
            return
        }
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return
        }
        guard !GC.isAchievementCompleted(achievementIdentifier: achievementIdentifier) else {
            GC.printLogGC("Achievement is already completed")
            return
        }
        
        guard let achievement = GC.getAchievementForIndentifier(identifierAchievement: achievementIdentifier) else {
            GC.printLogGC("No Achievement for identifier")
            return
        }
        
        let currentValue = achievement.percentComplete
        let newProgress: Double = !addToExisting ? progress : progress + currentValue
        
        achievement.percentComplete = newProgress
        
        /* show banner only if achievement is fully granted (progress is 100%) */
        if achievement.completed && showBannnerIfCompleted {
            GC.printLogGC("Achievement \(achievementIdentifier) completed")
            
            if GC.isConnectedToNetwork {
                achievement.showsCompletionBanner = true
            } else {
                //oneAchievement.showsCompletionBanner = true << Bug For not show two banner
                // Force show Banner when player not have network
                GC.getTupleGKAchievementAndDescription(achievementIdentifier: achievementIdentifier, completion: {
                    (tupleGKAchievementAndDescription) -> Void in
                    
                    if let tupleIsOK = tupleGKAchievementAndDescription {
                        let title = tupleIsOK.gkAchievementDescription.title
                        let description = tupleIsOK.gkAchievementDescription.achievedDescription
                        
                        GC.showCustomBanner(title: title!, description: description!)
                    }
                })
            }
        }
        if  achievement.completed && !showBannnerIfCompleted {
            GC.sharedInstance.achievementsCacheShowAfter[achievementIdentifier] = achievementIdentifier
        }
        GC.sharedInstance.reportAchievementToGameCenter(achievement: achievement)
    }

    public class func getGKAllAchievementDescription(completion completion: ((arrayGKAD:Set<GKAchievementDescription>?) -> Void)){
        
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return
        }
        
        guard GC.sharedInstance.achievementsDescriptionCache.count > 0 else {
            GCError.NoAchievement.printError()
            return
        }
        
        var tempsEnvoi = Set<GKAchievementDescription>()
        for achievementDes in GC.sharedInstance.achievementsDescriptionCache {
            tempsEnvoi.insert(achievementDes.1)
        }
        completion(arrayGKAD: tempsEnvoi)
    }
    
    public class func isAchievementCompleted(achievementIdentifier achievementIdentifier: String) -> Bool{
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return false
        }
        guard let achievement = GC.getAchievementForIndentifier(identifierAchievement: achievementIdentifier)
            where achievement.completed || achievement.percentComplete == 100.00 else {
                return false
        }
        return true
    }
    
    public class func getAchievementCompleteAndBannerNotShowing() -> [GKAchievement]? {
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return nil
        }
        
        let achievements : [String:String] = GC.sharedInstance.achievementsCacheShowAfter
        var achievementsTemps = [GKAchievement]()
        
        if achievements.count > 0 {
            
            for achievement in achievements  {
                if let achievementExtract = GC.getAchievementForIndentifier(identifierAchievement: achievement.1) {
                    if achievementExtract.completed && achievementExtract.showsCompletionBanner == false {
                        achievementsTemps.append(achievementExtract)
                    }
                }
            }
            return achievementsTemps
        }
        return nil
    }
    
    public class func showAllBannerAchievementCompleteForBannerNotShowing(completion: ((achievementShow:GKAchievement?) -> Void)? = nil) {
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            if completion != nil { completion!(achievementShow: nil) }
            return
        }
        guard let achievementNotShow: [GKAchievement] = GC.getAchievementCompleteAndBannerNotShowing()  else {
            
            if completion != nil { completion!(achievementShow: nil) }
            return
        }
        
        
        for achievement in achievementNotShow  {
            
            GC.getTupleGKAchievementAndDescription(achievementIdentifier: achievement.identifier!, completion: {
                (tupleGKAchievementAndDescription) in
                
                guard let tupleOK = tupleGKAchievementAndDescription   else {
                    
                    if completion != nil { completion!(achievementShow: nil) }
                    return
                }
                
                //oneAchievement.showsCompletionBanner = true
                let title = tupleOK.gkAchievementDescription.title
                let description = tupleOK.gkAchievementDescription.achievedDescription
                
                GC.showCustomBanner(title: title!, description: description!, completion: {
                    
                    if completion != nil { completion!(achievementShow: achievement) }
                })
                
            })
        }
        GC.sharedInstance.achievementsCacheShowAfter.removeAll(keepCapacity: false)
    }

    public class func getProgressForAchievement(achievementIdentifier achievementIdentifier:String) -> Double? {
        
        guard achievementIdentifier != "" else {
            GCError.Empty.errorCall()
            return nil
        }
        
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return nil
        }
        
        if let achievementInArrayInt = GC.sharedInstance.achievementsCache[achievementIdentifier]?.percentComplete {
            return achievementInArrayInt
        } else {
            GCError.Error("No Achievement for achievementIdentifier : \(achievementIdentifier)").errorCall()
            GCError.NoAchievement.errorCall()
            return nil
        }
        
    }
    
    public class func resetAllAchievements( completion:  ((achievementReset:GKAchievement?) -> Void)? = nil)  {
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            if completion != nil { completion!(achievementReset: nil) }
            return
        }
        
        
        GKAchievement.resetAchievementsWithCompletionHandler({
            (error:NSError?) in
            guard error == nil else {
                GC.printLogGC("Couldn't Reset achievement (Send data error)")
                return
            }
            
            
            for lookupAchievement in Static.instance!.achievementsCache {
                let achievementID = lookupAchievement.0
                let achievementGK = lookupAchievement.1
                achievementGK.percentComplete = 0
                achievementGK.showsCompletionBanner = false
                if completion != nil { completion!(achievementReset:achievementGK) }
                GC.printLogGC("Reset achievement (\(achievementID))")
            }
            
        })
    }
    
    public class func findMatchWithMinPlayers(minPlayers: Int, maxPlayers: Int) {
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return
        }
        do {
            let delegatVC = try GC.sharedInstance.getDelegate()
            
            
            GC.disconnectMatch()
            
            let request = GKMatchRequest()
            request.minPlayers = minPlayers
            request.maxPlayers = maxPlayers
            
            
            let controlllerGKMatch = GKMatchmakerViewController(matchRequest: request)
            controlllerGKMatch!.matchmakerDelegate = GC.sharedInstance
            
            var delegeteParent:UIViewController? = delegatVC.parentViewController
            if delegeteParent == nil {
                delegeteParent = delegatVC
            }
            delegeteParent!.presentViewController(controlllerGKMatch!, animated: true, completion: nil)
            
        } catch GCError.NoDelegate {
            GCError.NoDelegate.errorCall()
            
        } catch {
            fatalError("Dont work\(error)")
        }
    }
    
    public class func getPlayerInMatch() -> Set<GKPlayer>? {
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return nil
        }
        
        guard GC.sharedInstance.match != nil && GC.sharedInstance.playersInMatch.count > 0  else {
            GC.printLogGC("No Match")
            return nil
        }
        
        return GC.sharedInstance.playersInMatch
    }
    /**
     Deconnect the Match
     */
    public class func disconnectMatch() {
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return
        }
        guard let match = GC.sharedInstance.match else {
            return
        }
        
        GC.printLogGC("Disconnect from match")
        match.disconnect()
        GC.sharedInstance.match = nil
        (self.delegate as? GCDelegate)?.GCMatchEnded?()
        
    }
    
    public class func getMatch() -> GKMatch? {
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return nil
        }
        
        guard let match = GC.sharedInstance.match else {
            GC.printLogGC("No Match")
            return nil
        }
        
        return match
    }
    
    @available(iOS 8.0, *)
    private func lookupPlayers() {
        
        guard let match =  GC.sharedInstance.match else {
            GC.printLogGC("No Match")
            return
        }
        
        
        let playerIDs = match.players.map { $0.playerID }
        
        guard let hasePlayerIDS = playerIDs as? [String] else {
            GC.printLogGC("No Player")
            return
        }
        
        /* Load an array of player */
        GKPlayer.loadPlayersForIdentifiers(hasePlayerIDS) {
            (players, error) in
            
            guard error == nil else {
                GC.printLogGC("Error retrieving player info: \(error!.localizedDescription)")
                GC.disconnectMatch()
                return
            }
            
            guard let players = players else {
                GC.printLogGC("Error retrieving players; returned nil")
                return
            }
            if GC.debugMode {
                for player in players {
                    GC.printLogGC("Found player: \(player.alias)")
                }
            }
            
            if let arrayPlayers = players as [GKPlayer]? { self.playersInMatch = Set(arrayPlayers) }
            
            GKMatchmaker.sharedMatchmaker().finishMatchmakingForMatch(match)
            (Static.delegate as? GCDelegate)?.GCMatchStarted?()
            
        }
    }

    public class func sendDataToAllPlayers(data: NSData!, modeSend:GKMatchSendDataMode) {
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return
        }
        guard let match = GC.sharedInstance.match else {
            GC.printLogGC("No Match")
            return
        }
        
        do {
            try match.sendDataToAllPlayers(data, withDataMode: modeSend)
            GC.printLogGC("Succes sending data all Player")
        } catch  {
            GC.disconnectMatch()
            (Static.delegate as? GCDelegate)?.GCMatchEnded?()
            GC.printLogGC("Fail sending data all Player")
        }
    }

    class private var sharedInstance : GC {
        
        guard let instance = Static.instance else {
            GCError.Error("No Instance, please sharedInstance of EasyGameCenter").errorCall()
            fatalError("No Instance, please sharedInstance of EasyGameCenter")
        }
        return instance
    }

    private func getDelegate() throws -> UIViewController {
        guard let delegate = Static.delegate else {
            throw GCError.NoDelegate
        }
        return delegate
    }
    
    private static func completionCachingAchievements(achievementsType :[AnyObject]?) {
        
        func finish() {
            if GC.sharedInstance.achievementsCache.count > 0 &&
                GC.sharedInstance.achievementsDescriptionCache.count > 0 {
                
                (Static.delegate as? GCDelegate)?.GCInCache?()
                
            }
        }
        
        
        // Type GKAchievement
        if achievementsType is [GKAchievement] {
            
            guard let arrayGKAchievement = achievementsType as? [GKAchievement] where arrayGKAchievement.count > 0 else {
                GCError.CantCachingGKAchievement.errorCall()
                return
            }
            
            for anAchievement in arrayGKAchievement where  anAchievement.identifier != nil {
                GC.sharedInstance.achievementsCache[anAchievement.identifier!] = anAchievement
            }
            finish()
            
            // Type GKAchievementDescription
        } else if achievementsType is [GKAchievementDescription] {
            
            guard let arrayGKAchievementDes = achievementsType as? [GKAchievementDescription] where arrayGKAchievementDes.count > 0 else {
                GCError.CantCachingGKAchievementDescription.errorCall()
                return
            }
            
            for anAchievementDes in arrayGKAchievementDes where  anAchievementDes.identifier != nil {
                
                // Add GKAchievement
                if GC.sharedInstance.achievementsCache.indexForKey(anAchievementDes.identifier!) == nil {
                    GC.sharedInstance.achievementsCache[anAchievementDes.identifier!] = GKAchievement(identifier: anAchievementDes.identifier!)
                    
                }
                // Add CGAchievementDescription
                GC.sharedInstance.achievementsDescriptionCache[anAchievementDes.identifier!] = anAchievementDes
            }
            
            GKAchievement.loadAchievementsWithCompletionHandler({
                (allAchievements, error) in
                
                guard (error == nil) && allAchievements!.count != 0  else {
                    finish()
                    return
                }
                
                GC.completionCachingAchievements(allAchievements)
                
            })
        }
    }

    private func cachingAchievements() {
        guard GC.isConnectedToNetwork else {
            GCError.NoConnection.errorCall()
            return
        }
        guard GC.isPlayerIdentified else {
            GCError.NotLogin.errorCall()
            return
        }
        // Load GKAchievementDescription
        GKAchievementDescription.loadAchievementDescriptionsWithCompletionHandler({
            (achievementsDescription, error) in
            guard error == nil else {
                GCError.Error(error?.localizedDescription).errorCall()
                return
            }
            GC.completionCachingAchievements(achievementsDescription)
        })
    }
    
    internal func authenticationChanged() {
        guard let delegateGC = Static.delegate as? GCDelegate else {
            return
        }
        if GC.isPlayerIdentified {
            delegateGC.GCAuthentified?(true)
            GC.sharedInstance.cachingAchievements()
        } else {
            delegateGC.GCAuthentified?(false)
        }
    }
    
    private func loginPlayerToGameCenter()  {
        
        guard !GC.isPlayerIdentified else {
            return
        }
        
        guard let delegateVC = Static.delegate  else {
            GCError.NoDelegate.errorCall()
            return
        }
        
        guard GC.isConnectedToNetwork else {
            GCError.NoConnection.errorCall()
            return
        }
        
        GKLocalPlayer.localPlayer().authenticateHandler = {
            (gameCenterVC, error) in
            
            guard error == nil else {
                GCError.Error("User has canceled authentication").errorCall()
                return
            }
            guard let gcVC = gameCenterVC else {
                return
            }
            if GC.showLoginPage {
                dispatch_async(dispatch_get_main_queue()) {
                    delegateVC.presentViewController(gcVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func checkupNetAndPlayer() {
        dispatch_async(dispatch_get_main_queue()) {
            if self.timerNetAndPlayer == nil {
                self.timerNetAndPlayer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GC.checkupNetAndPlayer), userInfo: nil, repeats: true)
            }
            
            if GC.isConnectedToNetwork {
                self.timerNetAndPlayer!.invalidate()
                self.timerNetAndPlayer = nil
                
                GC.sharedInstance.loginPlayerToGameCenter()
            }
        }
    }
    
    private func reportAchievementToGameCenter(achievement achievement:GKAchievement) {
        /* try to report the progress to the Game Center */
        
        GKAchievement.reportAchievements([achievement], withCompletionHandler:  {
            (error:NSError?) -> Void in
            if error != nil { /* Game Center Save Automatique */ }
        })
    }
    
    public func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    public func match(theMatch: GKMatch, didReceiveData data: NSData, fromPlayer playerID: String) {
        guard GC.sharedInstance.match == theMatch else {
            return
        }
        (Static.delegate as? GCDelegate)?.GCMatchRecept?(theMatch, didReceiveData: data, fromPlayer: playerID)
        
    }
 
    public func match(theMatch: GKMatch, player playerID: String, didChangeState state: GKPlayerConnectionState) {

        guard self.match == theMatch else {
            return
        }
        
        switch state {

        case .StateConnected where self.match != nil && theMatch.expectedPlayerCount == 0:
            self.lookupPlayers()
        case .StateDisconnected:
            GC.disconnectMatch()
        default:
            break
        }
    }

    public func match(theMatch: GKMatch, didFailWithError error: NSError?) {
        guard self.match == theMatch else {
            return
        }
        
        guard error == nil else {
            GCError.Error("Match failed with error: \(error?.localizedDescription)").errorCall()
            GC.disconnectMatch()
            return
        }
    }
    
    public func matchmakerViewController(viewController: GKMatchmakerViewController, didFindMatch theMatch: GKMatch) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        self.match = theMatch
        self.match!.delegate = self
        if match!.expectedPlayerCount == 0 {
            self.lookupPlayers()
        }
    }
    
    public func player(player: GKPlayer, didAcceptInvite inviteToAccept: GKInvite) {
        guard let gkmv = GKMatchmakerViewController(invite: inviteToAccept) else {
            GCError.Error("GKMatchmakerViewController invite to accept nil").errorCall()
            return
        }
        gkmv.matchmakerDelegate = self
        
        var delegeteParent:UIViewController? = GC.delegate.parentViewController
        if delegeteParent == nil {
            delegeteParent = GC.delegate
        }
        delegeteParent!.presentViewController(gkmv, animated: true, completion: nil)
    }
    
    public func player(player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) { }

    public func player(player: GKPlayer, didRequestMatchWithPlayers playerIDsToInvite: [String]) { }
    
    public func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController) {
        
        viewController.dismissViewControllerAnimated(true, completion: nil)
        
        (Static.delegate as? GCDelegate)?.GCMatchCancel?()
        GC.printLogGC("Player cancels the matchmaking request")
        
    }
    
    public func matchmakerViewController(viewController: GKMatchmakerViewController, didFailWithError error: NSError) {
        
        viewController.dismissViewControllerAnimated(true, completion: nil)
        (Static.delegate as? GCDelegate)?.GCMatchCancel?()
        GCError.Error("Error finding match: \(error.localizedDescription)\n").errorCall()
        
    }
}

extension GC {
    
    private class func printLogGC(object: Any) {
        if GC.debugMode {
            dispatch_async(dispatch_get_main_queue()) {
                Swift.print("\n[Easy Game Center] \(object)\n")
            }
        }
    }
}

extension GC {
    
    private enum GCError : ErrorType {
        case Error(String?)
        case CantCachingGKAchievementDescription
        case CantCachingGKAchievement
        case NoAchievement
        case Empty
        case NoConnection
        case NotLogin
        case NoDelegate
        
        var description : String {
            
            switch self {
                
            case .Error(let error):
                return (error != nil) ? "\(error!)" : "\(error)"
                
            case .CantCachingGKAchievementDescription:
                return "Can't caching GKAchievementDescription\n( Have you create achievements in ItuneConnect ? )"
                
            case .CantCachingGKAchievement:
                return "Can' t caching GKAchievement\n( Have you create achievements in ItuneConnect ? )"
                
            case .NoAchievement:
                return "No GKAchievement and GKAchievementDescription\n\n( Have you create achievements in ItuneConnect ? )"
                
            case .NoConnection:
                return "No internet connection"
                
            case .NotLogin:
                return "User is not identified to game center"
                
            case .NoDelegate :
                return "\nDelegate UIViewController not added"
                
            case .Empty:
                return "\nThe parameter is empty"
            }
        }
        
        private func printError(error: GCError) {
            GC.printLogGC(error.description)
        }

        private func printError() {
            GC.printLogGC(self.description)
        }

        private func errorCall() {
            
            defer { self.printError() }
            
            switch self {
            case .NotLogin:
                (GC.delegate  as? GCDelegate)?.GCAuthentified?(false)
                break
            case .CantCachingGKAchievementDescription:
                GC.sharedInstance.checkupNetAndPlayer()
                break
            case .CantCachingGKAchievement:
                
                break
            default:
                break
            }
        }
    }
}