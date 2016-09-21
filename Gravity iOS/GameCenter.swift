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

    @objc optional func GCAuthentified(_ authentified:Bool)

    @objc optional func GCInCache()

    @objc optional func GCMatchStarted()

    @objc optional func GCMatchRecept(_ match: GKMatch, didReceiveData: Data, fromPlayer: String)

    @objc optional func GCMatchEnded()

    @objc optional func GCMatchCancel()
}

extension GC {

    static var isConnectedToNetwork: Bool {
        
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
}

open class GC: NSObject, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate, GKLocalPlayerListener {

    private static var __once: () = {
                Static.instance = GC()
                Static.delegate = delegate
                Static.instance!.loginPlayerToGameCenter()
            }()

    fileprivate var achievementsCache:[String:GKAchievement] = [String:GKAchievement]()
    fileprivate var achievementsDescriptionCache = [String:GKAchievementDescription]()
    fileprivate var achievementsCacheShowAfter = [String:String]()
    fileprivate var timerNetAndPlayer:Timer?
    fileprivate var debugModeGetSet:Bool = false
    static var showLoginPage:Bool = true
    fileprivate var match: GKMatch?
    fileprivate var playersInMatch = Set<GKPlayer>()
    open var invitedPlayer: GKPlayer?
    open var invite: GKInvite?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(GC.authenticationChanged), name: NSNotification.Name(rawValue: GKPlayerAuthenticationDidChangeNotificationName), object: nil)
    }

    struct Static {
        static var onceToken: Int = 0
        static var instance: GC? = nil
        static weak var delegate: UIViewController? = nil
    }
    
    open class func sharedInstance(_ delegate:UIViewController)-> GC {
        if Static.instance == nil {
            Static.instance = GC()
            Static.delegate = delegate
            Static.instance!.loginPlayerToGameCenter()
            //}
        }
        return Static.instance!
    }

    class var delegate: UIViewController {
        get {
            do {
                let delegateInstance = try GC.sharedInstance.getDelegate()
                return delegateInstance
            } catch  {
                GCError.noDelegate.errorCall()
                fatalError(error.localizedDescription)
            }
        }
        
        set {
            guard newValue != GC.delegate else {
                return
            }
            Static.delegate = GC.delegate
        }
    }

    open class var debugMode:Bool {
        get {
            return GC.sharedInstance.debugModeGetSet
        }
        set {
            GC.sharedInstance.debugModeGetSet = newValue
        }
    }

    open static var isPlayerIdentified: Bool {
        get {
            return GKLocalPlayer.localPlayer().isAuthenticated
        }
    }
    
    static var localPayer: GKLocalPlayer {
        get {
            return GKLocalPlayer.localPlayer()
        }
    }
    
    class func getlocalPlayerInformation(completion completionTuple: @escaping (_ playerInformationTuple:(playerID:String,alias:String,profilPhoto:UIImage?)?) -> ()) {
        
        guard GC.isConnectedToNetwork else {
            completionTuple(nil)
            GCError.noConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            completionTuple(nil)
            GCError.notLogin.errorCall()
            return
        }
        
        GC.localPayer.loadPhoto(forSize: GKPhotoSizeNormal, withCompletionHandler: {
            (image, error) in
            
            var playerInformationTuple:(playerID:String,alias:String,profilPhoto:UIImage?)
            playerInformationTuple.profilPhoto = nil
            
            playerInformationTuple.playerID = GC.localPayer.playerID!
            playerInformationTuple.alias = GC.localPayer.alias!
            if error == nil { playerInformationTuple.profilPhoto = image }
            completionTuple(playerInformationTuple)
        })
    }
    
    open class func showGameCenter(_ completion: ((_ isShow:Bool) -> Void)? = nil) {
        
        guard GC.isConnectedToNetwork else {
            if completion != nil { completion!(false) }
            GCError.noConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            if completion != nil { completion!(false) }
            GCError.notLogin.errorCall()
            return
        }
        
        
        GC.printLogGC("Show Game Center")
        
        let gc                = GKGameCenterViewController()
        gc.gameCenterDelegate = Static.instance
        
        #if !os(tvOS)
            gc.viewState          = GKGameCenterViewControllerState.default
        #endif
        
        var delegeteParent:UIViewController? = GC.delegate.parent
        if delegeteParent == nil {
            delegeteParent = GC.delegate
        }
        delegeteParent!.present(gc, animated: true, completion: {
            if completion != nil { completion!(true) }
        })
        
    }
    
    open class func showGameCenterAchievements(_ completion: ((_ isShow:Bool) -> Void)? = nil) {
        
        guard GC.isConnectedToNetwork else {
            if completion != nil { completion!(false) }
            GCError.noConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            if completion != nil { completion!(false) }
            GCError.notLogin.errorCall()
            return
        }
        
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = Static.instance
        #if !os(tvOS)
            gc.viewState = GKGameCenterViewControllerState.achievements
        #endif
        
        var delegeteParent:UIViewController? = GC.delegate.parent
        if delegeteParent == nil {
            delegeteParent = GC.delegate
        }
        delegeteParent!.present(gc, animated: true, completion: {
            if completion != nil { completion!(true) }
        })
    }
    
    open class func showGameCenterLeaderboard(leaderboardIdentifier :String, completion: ((_ isShow:Bool) -> Void)? = nil) {
        
        guard leaderboardIdentifier != "" else {
            GCError.empty.errorCall()
            if completion != nil { completion!(false) }
            return
        }
        
        guard GC.isConnectedToNetwork else {
            GCError.noConnection.errorCall()
            if completion != nil { completion!(false) }
            return
        }
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            if completion != nil { completion!(false) }
            return
        }
        
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = Static.instance
        #if !os(tvOS)
            gc.leaderboardIdentifier = leaderboardIdentifier
            gc.viewState = GKGameCenterViewControllerState.leaderboards
        #endif
        
        var delegeteParent:UIViewController? = GC.delegate.parent
        if delegeteParent == nil {
            delegeteParent = GC.delegate
        }
        delegeteParent!.present(gc, animated: true, completion: {
            if completion != nil { completion!(true) }
        })
        
    }

    open class func showGameCenterChallenges(_ completion: ((_ isShow:Bool) -> Void)? = nil) {
        
        guard GC.isConnectedToNetwork else {
            if completion != nil { completion!(false) }
            GCError.noConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            if completion != nil { completion!(false) }
            GCError.notLogin.errorCall()
            return
        }
        
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate =  Static.instance
        #if !os(tvOS)
            gc.viewState = GKGameCenterViewControllerState.challenges
        #endif
        
        var delegeteParent:UIViewController? =  GC.delegate.parent
        if delegeteParent == nil {
            delegeteParent =  GC.delegate
        }
        delegeteParent!.present(gc, animated: true, completion: {
            () -> Void in
            
            if completion != nil { completion!(true) }
        })
        
    }
    
    open class func showCustomBanner(title:String, description:String,completion: (() -> Void)? = nil) {
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return
        }
        
        GKNotificationBanner.show(withTitle: title, message: description, completionHandler: completion)
    }
    
    open class func showGameCenterAuthentication(_ completion: ((_ result:Bool) -> Void)? = nil) {
        if completion != nil {
            completion!(UIApplication.shared.openURL(URL(string: "gamecenter:")!))
        }
    }
    
    open class func getGKLeaderboard(completion: @escaping ((_ resultArrayGKLeaderboard:Set<GKLeaderboard>?) -> Void)) {
        
        guard GC.isConnectedToNetwork else {
            completion(nil)
            GCError.noConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            completion(nil)
            GCError.notLogin.errorCall()
            return
        }
        
        GKLeaderboard.loadLeaderboards {
            (leaderboards, error) in
            
            guard GC.isPlayerIdentified else {
                completion(nil)
                GCError.notLogin.errorCall()
                return
            }
            
            guard let leaderboardsIsArrayGKLeaderboard = leaderboards as [GKLeaderboard]? else {
                completion(nil)
                GCError.error(error?.localizedDescription).errorCall()
                return
            }
            
            completion(Set(leaderboardsIsArrayGKLeaderboard))
            
        }
    }
    
    open class func reportScoreLeaderboard(leaderboardIdentifier:String, score: Int) {
        guard GC.isConnectedToNetwork else {
            GCError.noConnection.errorCall()
            return
        }
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return
        }
        
        let gkScore = GKScore(leaderboardIdentifier: leaderboardIdentifier)
        gkScore.value = Int64(score)
        gkScore.shouldSetDefaultLeaderboard = true
        GKScore.report([gkScore], withCompletionHandler: nil)
    }
    
    open class func getHighScore(
        leaderboardIdentifier:String,
                              completion:@escaping (((playerName:String, score:Int,rank:Int)?) -> Void)
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
    
    open class func  getGKScoreLeaderboard(leaderboardIdentifier:String, completion:@escaping ((_ resultGKScore:GKScore?) -> Void)) {
        
        guard leaderboardIdentifier != "" else {
            GCError.empty.errorCall()
            completion(nil)
            return
        }
        
        guard GC.isConnectedToNetwork else {
            GCError.noConnection.errorCall()
            completion(nil)
            return
        }
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
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

    open class func getTupleGKAchievementAndDescription(achievementIdentifier:String,completion completionTuple: ((_ tupleGKAchievementAndDescription:(gkAchievement:GKAchievement,gkAchievementDescription:GKAchievementDescription)?) -> Void)) {
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            completionTuple(nil)
            return
        }
        
        let achievementGKScore = GC.sharedInstance.achievementsCache[achievementIdentifier]
        let achievementGKDes =  GC.sharedInstance.achievementsDescriptionCache[achievementIdentifier]
        
        guard let aGKS = achievementGKScore, let aGKD = achievementGKDes else {
            completionTuple(nil)
            return
        }
        
        completionTuple((aGKS,aGKD))
        
    }
    
    open class func getAchievementForIndentifier(identifierAchievement : NSString) -> GKAchievement? {
        
        guard identifierAchievement != "" else {
            GCError.empty.errorCall()
            return nil
        }
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return nil
        }
        
        guard let achievementFind = GC.sharedInstance.achievementsCache[identifierAchievement as String] else {
            return nil
        }
        return achievementFind
    }
    
    open class func reportAchievement( progress : Double, achievementIdentifier : String, showBannnerIfCompleted : Bool = true ,addToExisting: Bool = false) {
        
        guard achievementIdentifier != "" else {
            GCError.empty.errorCall()
            return
        }
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return
        }
        guard !GC.isAchievementCompleted(achievementIdentifier: achievementIdentifier) else {
            GC.printLogGC("Achievement is already completed")
            return
        }
        
        guard let achievement = GC.getAchievementForIndentifier(identifierAchievement: achievementIdentifier as NSString) else {
            GC.printLogGC("No Achievement for identifier")
            return
        }
        
        let currentValue = achievement.percentComplete
        let newProgress: Double = !addToExisting ? progress : progress + currentValue
        
        achievement.percentComplete = newProgress
        
        /* show banner only if achievement is fully granted (progress is 100%) */
        if achievement.isCompleted && showBannnerIfCompleted {
            GC.printLogGC("Achievement \(achievementIdentifier) completed")
            
            if GC.isConnectedToNetwork {
                achievement.showsCompletionBanner = true
            } else {
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
        if  achievement.isCompleted && !showBannnerIfCompleted {
            GC.sharedInstance.achievementsCacheShowAfter[achievementIdentifier] = achievementIdentifier
        }
        GC.sharedInstance.reportAchievementToGameCenter(achievement: achievement)
    }

    open class func getGKAllAchievementDescription(completion: ((_ arrayGKAD:Set<GKAchievementDescription>?) -> Void)){
        
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return
        }
        
        guard GC.sharedInstance.achievementsDescriptionCache.count > 0 else {
            GCError.noAchievement.printError()
            return
        }
        
        var tempsEnvoi = Set<GKAchievementDescription>()
        for achievementDes in GC.sharedInstance.achievementsDescriptionCache {
            tempsEnvoi.insert(achievementDes.1)
        }
        completion(tempsEnvoi)
    }
    
    open class func isAchievementCompleted(achievementIdentifier: String) -> Bool{
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return false
        }
        guard let achievement = GC.getAchievementForIndentifier(identifierAchievement: achievementIdentifier as NSString)
            , achievement.isCompleted || achievement.percentComplete == 100.00 else {
                return false
        }
        return true
    }
    
    open class func getAchievementCompleteAndBannerNotShowing() -> [GKAchievement]? {
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return nil
        }
        
        let achievements : [String:String] = GC.sharedInstance.achievementsCacheShowAfter
        var achievementsTemps = [GKAchievement]()
        
        if achievements.count > 0 {
            
            for achievement in achievements  {
                if let achievementExtract = GC.getAchievementForIndentifier(identifierAchievement: achievement.1 as NSString) {
                    if achievementExtract.isCompleted && achievementExtract.showsCompletionBanner == false {
                        achievementsTemps.append(achievementExtract)
                    }
                }
            }
            return achievementsTemps
        }
        return nil
    }
    
    open class func showAllBannerAchievementCompleteForBannerNotShowing(_ completion: ((_ achievementShow:GKAchievement?) -> Void)? = nil) {
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            if completion != nil { completion!(nil) }
            return
        }
        guard let achievementNotShow: [GKAchievement] = GC.getAchievementCompleteAndBannerNotShowing()  else {
            
            if completion != nil { completion!(nil) }
            return
        }
        
        
        for achievement in achievementNotShow  {
            
            GC.getTupleGKAchievementAndDescription(achievementIdentifier: achievement.identifier!, completion: {
                (tupleGKAchievementAndDescription) in
                
                guard let tupleOK = tupleGKAchievementAndDescription   else {
                    
                    if completion != nil { completion!(nil) }
                    return
                }
                
                let title = tupleOK.gkAchievementDescription.title
                let description = tupleOK.gkAchievementDescription.achievedDescription
                
                GC.showCustomBanner(title: title!, description: description!, completion: {
                    
                    if completion != nil { completion!(achievement) }
                })
                
            })
        }
        GC.sharedInstance.achievementsCacheShowAfter.removeAll(keepingCapacity: false)
    }

    open class func getProgressForAchievement(achievementIdentifier:String) -> Double? {
        
        guard achievementIdentifier != "" else {
            GCError.empty.errorCall()
            return nil
        }
        
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return nil
        }
        
        if let achievementInArrayInt = GC.sharedInstance.achievementsCache[achievementIdentifier]?.percentComplete {
            return achievementInArrayInt
        } else {
            GCError.error("No Achievement for achievementIdentifier : \(achievementIdentifier)").errorCall()
            GCError.noAchievement.errorCall()
            return nil
        }
        
    }
    
    open class func resetAllAchievements( _ completion:  ((_ achievementReset:GKAchievement?) -> Void)? = nil)  {
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            if completion != nil { completion!(nil) }
            return
        }
        
        
        GKAchievement.resetAchievements(completionHandler: {
            (error:Error?) in
            guard error == nil else {
                GC.printLogGC("Couldn't Reset achievement (Send data error)")
                return
            }
            
            
            for lookupAchievement in Static.instance!.achievementsCache {
                let achievementID = lookupAchievement.0
                let achievementGK = lookupAchievement.1
                achievementGK.percentComplete = 0
                achievementGK.showsCompletionBanner = false
                if completion != nil { completion!(achievementGK) }
                GC.printLogGC("Reset achievement (\(achievementID))")
            }
            
        })
    }
    
    open class func findMatchWithMinPlayers(_ minPlayers: Int, maxPlayers: Int) {
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
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
            
            var delegeteParent:UIViewController? = delegatVC.parent
            if delegeteParent == nil {
                delegeteParent = delegatVC
            }
            delegeteParent!.present(controlllerGKMatch!, animated: true, completion: nil)
            
        } catch GCError.noDelegate {
            GCError.noDelegate.errorCall()
            
        } catch {
            fatalError("Dont work\(error)")
        }
    }
    
    open class func getPlayerInMatch() -> Set<GKPlayer>? {
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
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
    open class func disconnectMatch() {
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
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
    
    open class func getMatch() -> GKMatch? {
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return nil
        }
        
        guard let match = GC.sharedInstance.match else {
            GC.printLogGC("No Match")
            return nil
        }
        
        return match
    }
    
    @available(iOS 8.0, *)
    fileprivate func lookupPlayers() {
        
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
        GKPlayer.loadPlayers(forIdentifiers: hasePlayerIDS) {
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
            
            GKMatchmaker.shared().finishMatchmaking(for: match)
            (Static.delegate as? GCDelegate)?.GCMatchStarted?()
            
        }
    }

    open class func sendDataToAllPlayers(_ data: Data!, modeSend:GKMatchSendDataMode) {
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return
        }
        guard let match = GC.sharedInstance.match else {
            GC.printLogGC("No Match")
            return
        }
        
        do {
            try match.sendData(toAllPlayers: data, with: modeSend)
            GC.printLogGC("Succes sending data all Player")
        } catch  {
            GC.disconnectMatch()
            (Static.delegate as? GCDelegate)?.GCMatchEnded?()
            GC.printLogGC("Fail sending data all Player")
        }
    }

    class fileprivate var sharedInstance : GC {
        
        guard let instance = Static.instance else {
            GCError.error("No Instance, please sharedInstance of EasyGameCenter").errorCall()
            fatalError("No Instance, please sharedInstance of EasyGameCenter")
        }
        return instance
    }

    fileprivate func getDelegate() throws -> UIViewController {
        guard let delegate = Static.delegate else {
            throw GCError.noDelegate
        }
        return delegate
    }
    
    fileprivate static func completionCachingAchievements(_ achievementsType :[AnyObject]?) {
        
        func finish() {
            if GC.sharedInstance.achievementsCache.count > 0 &&
                GC.sharedInstance.achievementsDescriptionCache.count > 0 {
                
                (Static.delegate as? GCDelegate)?.GCInCache?()
                
            }
        }
        
        
        // Type GKAchievement
        if achievementsType is [GKAchievement] {
            
            guard let arrayGKAchievement = achievementsType as? [GKAchievement] , arrayGKAchievement.count > 0 else {
                GCError.cantCachingGKAchievement.errorCall()
                return
            }
            
            for anAchievement in arrayGKAchievement where  anAchievement.identifier != nil {
                GC.sharedInstance.achievementsCache[anAchievement.identifier!] = anAchievement
            }
            finish()
            
            // Type GKAchievementDescription
        } else if achievementsType is [GKAchievementDescription] {
            
            guard let arrayGKAchievementDes = achievementsType as? [GKAchievementDescription] , arrayGKAchievementDes.count > 0 else {
                GCError.cantCachingGKAchievementDescription.errorCall()
                return
            }
            
            for anAchievementDes in arrayGKAchievementDes where  anAchievementDes.identifier != nil {
                
                // Add GKAchievement
                if GC.sharedInstance.achievementsCache.index(forKey: anAchievementDes.identifier!) == nil {
                    GC.sharedInstance.achievementsCache[anAchievementDes.identifier!] = GKAchievement(identifier: anAchievementDes.identifier!)
                    
                }
                // Add CGAchievementDescription
                GC.sharedInstance.achievementsDescriptionCache[anAchievementDes.identifier!] = anAchievementDes
            }
            
            GKAchievement.loadAchievements(completionHandler: {
                (allAchievements, error) in
                
                guard (error == nil) && allAchievements!.count != 0  else {
                    finish()
                    return
                }
                
                GC.completionCachingAchievements(allAchievements)
                
            })
        }
    }

    fileprivate func cachingAchievements() {
        guard GC.isConnectedToNetwork else {
            GCError.noConnection.errorCall()
            return
        }
        guard GC.isPlayerIdentified else {
            GCError.notLogin.errorCall()
            return
        }
        // Load GKAchievementDescription
        GKAchievementDescription.loadAchievementDescriptions(completionHandler: {
            (achievementsDescription, error) in
            guard error == nil else {
                GCError.error(error?.localizedDescription).errorCall()
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
    
    fileprivate func loginPlayerToGameCenter()  {
        
        guard !GC.isPlayerIdentified else {
            return
        }
        
        guard let delegateVC = Static.delegate  else {
            GCError.noDelegate.errorCall()
            return
        }
        
        guard GC.isConnectedToNetwork else {
            GCError.noConnection.errorCall()
            return
        }
        
        GKLocalPlayer.localPlayer().authenticateHandler = {
            (gameCenterVC, error) in
            
            guard error == nil else {
                GCError.error("User has canceled authentication").errorCall()
                return
            }
            guard let gcVC = gameCenterVC else {
                return
            }
            if GC.showLoginPage {
                DispatchQueue.main.async {
                    delegateVC.present(gcVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func checkupNetAndPlayer() {
        DispatchQueue.main.async {
            if self.timerNetAndPlayer == nil {
                self.timerNetAndPlayer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GC.checkupNetAndPlayer), userInfo: nil, repeats: true)
            }
            
            if GC.isConnectedToNetwork {
                self.timerNetAndPlayer!.invalidate()
                self.timerNetAndPlayer = nil
                
                GC.sharedInstance.loginPlayerToGameCenter()
            }
        }
    }
    
    fileprivate func reportAchievementToGameCenter(achievement:GKAchievement) {
        /* try to report the progress to the Game Center */
        
        GKAchievement.report([achievement], withCompletionHandler:  {
            (error:Error?) -> Void in
            if error != nil { /* Game Center Save Automatique */ }
        })
    }
    
    open func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    open func match(_ theMatch: GKMatch, didReceive data: Data, fromPlayer playerID: String) {
        guard GC.sharedInstance.match == theMatch else {
            return
        }
        (Static.delegate as? GCDelegate)?.GCMatchRecept?(theMatch, didReceiveData: data, fromPlayer: playerID)
        
    }
 
    open func match(_ theMatch: GKMatch, player playerID: String, didChange state: GKPlayerConnectionState) {

        guard self.match == theMatch else {
            return
        }
        
        switch state {

        case .stateConnected where self.match != nil && theMatch.expectedPlayerCount == 0:
            self.lookupPlayers()
        case .stateDisconnected:
            GC.disconnectMatch()
        default:
            break
        }
    }

    open func match(_ theMatch: GKMatch, didFailWithError error: Error?) {
        guard self.match == theMatch else {
            return
        }
        
        guard error == nil else {
            GCError.error("Match failed with error: \(error?.localizedDescription)").errorCall()
            GC.disconnectMatch()
            return
        }
    }
    
    open func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind theMatch: GKMatch) {
        viewController.dismiss(animated: true, completion: nil)
        self.match = theMatch
        self.match!.delegate = self
        if match!.expectedPlayerCount == 0 {
            self.lookupPlayers()
        }
    }
    
    open func player(_ player: GKPlayer, didAccept inviteToAccept: GKInvite) {
        guard let gkmv = GKMatchmakerViewController(invite: inviteToAccept) else {
            GCError.error("GKMatchmakerViewController invite to accept nil").errorCall()
            return
        }
        gkmv.matchmakerDelegate = self
        
        var delegeteParent:UIViewController? = GC.delegate.parent
        if delegeteParent == nil {
            delegeteParent = GC.delegate
        }
        delegeteParent!.present(gkmv, animated: true, completion: nil)
    }
    
    open func player(_ player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) { }

    open func player(_ player: GKPlayer, didRequestMatchWithPlayers playerIDsToInvite: [String]) { }
    
    open func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        
        viewController.dismiss(animated: true, completion: nil)
        
        (Static.delegate as? GCDelegate)?.GCMatchCancel?()
        GC.printLogGC("Player cancels the matchmaking request")
        
    }
    
    open func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        
        viewController.dismiss(animated: true, completion: nil)
        (Static.delegate as? GCDelegate)?.GCMatchCancel?()
        GCError.error("Error finding match: \(error.localizedDescription)\n").errorCall()
        
    }
}

extension GC {
    
    fileprivate class func printLogGC(_ object: Any) {
        if GC.debugMode {
            DispatchQueue.main.async {
                Swift.print("\n[Easy Game Center] \(object)\n")
            }
        }
    }
}

extension GC {
    
    fileprivate enum GCError : Error {
        case error(String?)
        case cantCachingGKAchievementDescription
        case cantCachingGKAchievement
        case noAchievement
        case empty
        case noConnection
        case notLogin
        case noDelegate
        
        var description : String {
            
            switch self {
                
            case .error(let error):
                return (error != nil) ? "\(error!)" : "\(error)"
                
            case .cantCachingGKAchievementDescription:
                return "Can't caching GKAchievementDescription\n( Have you create achievements in ItuneConnect ? )"
                
            case .cantCachingGKAchievement:
                return "Can' t caching GKAchievement\n( Have you create achievements in ItuneConnect ? )"
                
            case .noAchievement:
                return "No GKAchievement and GKAchievementDescription\n\n( Have you create achievements in ItuneConnect ? )"
                
            case .noConnection:
                return "No internet connection"
                
            case .notLogin:
                return "User is not identified to game center"
                
            case .noDelegate :
                return "\nDelegate UIViewController not added"
                
            case .empty:
                return "\nThe parameter is empty"
            }
        }
        
        fileprivate func printError(_ error: GCError) {
            GC.printLogGC(error.description)
        }

        fileprivate func printError() {
            GC.printLogGC(self.description)
        }

        fileprivate func errorCall() {
            
            defer { self.printError() }
            
            switch self {
            case .notLogin:
                (GC.delegate  as? GCDelegate)?.GCAuthentified?(false)
                break
            case .cantCachingGKAchievementDescription:
                GC.sharedInstance.checkupNetAndPlayer()
                break
            case .cantCachingGKAchievement:
                
                break
            default:
                break
            }
        }
    }
}
