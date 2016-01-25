//
//  GameScene.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 13/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//

import SpriteKit
import EasyGameCenter

class GameScene: SKSceneExtension, SKPhysicsContactDelegate {
    
    //Enums
    enum ColliderType:UInt32 {
        case All = 0xFFFFFFFF
        case Player = 0b001
        case Ground = 0b010
        case Objects = 0b100
    }
    
    //Layers
    var menuLayer = MenuLayer()
    var gameLayer = GameLayer()
    var highscoreLayer = HighscoreLayer()
    
    //Vars
    var lastNodeName = ""
    var gravityDirection = "down"
    var moveLeft:Bool = false
    var moveRight:Bool = false
    var spawnTimer = NSTimer()
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    var stopTime = NSTimeInterval()
    var currentScore: NSTimeInterval = 0
    var newHighscore:Bool = false
    var gameCenterSync:Bool = false
    var gameBGColor:[SKColor] = []
    var gameObjectColor:[SKColor] = []
    var currentGameColor:Int = 0
    var isColorizing:Bool = false
    var barsFadedIn:Bool = true
    var gameRestarting:Bool = false
    var timerRunning:Bool = false
    var objectRotationPos:Int = 0
    var objectRotationNeg:Int = 360
    var objectsCanRotate:Bool = false
    var spawnTimerRunning:Bool = false
    var gameStarted:Bool = false
    
    //Actions
    var colorizeBGNodes = SKAction()
    var colorizeObjectNodes = SKAction()
    let fadeColorAction = SKAction.customActionWithDuration(0.5, actionBlock: {(node: SKNode!, elapsedTime: CGFloat) -> Void in
        if node is SKSpriteNode  {
            (node as! SKSpriteNode).alpha = 0.8
        } else if node is SKShapeNode {
            (node as! SKShapeNode).alpha = 0.8
        }
    })
    let fadeOutColorAction = SKAction.customActionWithDuration(0.5, actionBlock: {(node: SKNode!, elapsedTime: CGFloat) -> Void in
        if node is SKSpriteNode  {
            (node as! SKSpriteNode).alpha = 1.0
        } else if node is SKShapeNode {
            (node as! SKShapeNode).alpha = 1.0
        }
    })
    
    var waitAction:SKAction = SKAction()
    var moveLeftAction:SKAction = SKAction()
    var moveRightAction:SKAction = SKAction()
    var objectMoveRightAction:SKAction = SKAction()
    var objectMoveLeftAction:SKAction = SKAction()
    
    //Functions
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        loadValues()
        loadNSUserData()
        interfaceSetup()
    }
    
    func loadValues() {
        vars.screenSize = (view?.frame.size)!
        vars.barHeight = vars.screenSize.height / 6
        vars.objectSize = vars.screenSize.height / 36
        vars.screenOutLeft = -vars.objectSize * 2
        vars.screenOutRight = vars.screenSize.width + vars.objectSize * 2
        
        gameBGColor.append(colors.redBGColor)
        gameBGColor.append(colors.blueBGColor)
        gameBGColor.append(colors.greenBGColor)
        gameBGColor.append(colors.yellowBGColor)
        gameBGColor.append(colors.orangeBGColor)
        
        gameObjectColor.append(colors.redObjectColor)
        gameObjectColor.append(colors.blueObjectColor)
        gameObjectColor.append(colors.greenObjectColor)
        gameObjectColor.append(colors.yellowObjectColor)
        gameObjectColor.append(colors.orangeObjectColor)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimerAfter", name: "pauseGame", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startTimerAfter", name: "resumeGame", object: nil)
        
        waitAction = SKAction.waitForDuration(vars.objectWait)
        moveLeftAction = SKAction.sequence([
            waitAction,
            SKAction.moveToX(vars.screenOutLeft, duration: vars.objectMoveTime)
        ])
        moveRightAction = SKAction.sequence([
                waitAction,
            SKAction.moveToX(vars.screenOutRight, duration: vars.objectMoveTime)
        ])
    }
    
    func loadNSUserData() {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("highscore") {
            vars.highscore = NSUserDefaults.standardUserDefaults().doubleForKey("highscore")
        } else {
            vars.highscore = 0
        }
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("gamesPlayed") {
            vars.gamesPlayed = NSUserDefaults.standardUserDefaults().integerForKey("gamesPlayed")
        } else {
            vars.gamesPlayed = 0
        }
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("fiveSeconds") {
            achievements.fiveSeconds = NSUserDefaults.standardUserDefaults().boolForKey("fiveSeconds")
        } else {
            achievements.fiveSeconds = false
        }
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("tenSeconds") {
            achievements.tenSeconds = NSUserDefaults.standardUserDefaults().boolForKey("tenSeconds")
        } else {
            achievements.tenSeconds = false
        }
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("twentySeconds") {
            achievements.twentySeconds = NSUserDefaults.standardUserDefaults().boolForKey("twentySeconds")
        } else {
            achievements.twentySeconds = false
        }
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("thirtySeconds") {
            achievements.thirtySeconds = NSUserDefaults.standardUserDefaults().boolForKey("thirtySeconds")
        } else {
            achievements.thirtySeconds = false
        }
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("oneMinute") {
            achievements.oneMinute = NSUserDefaults.standardUserDefaults().boolForKey("oneMinute")
        } else {
            achievements.oneMinute = false
        }
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("oneHour") {
            achievements.oneHour = NSUserDefaults.standardUserDefaults().boolForKey("oneHour")
        } else {
            achievements.oneHour = false
        }
    }
    
    func changeColor() {
        if isColorizing == true {
            if currentGameColor <= gameBGColor.count - 2 {
                menuLayer.backgroundNode.runAction(colorTransitionAction(gameBGColor[currentGameColor], toColor: gameBGColor[currentGameColor + 1], duration: vars.colorChangeTime), completion: {
                    self.currentGameColor += 1
                    self.changeColor()
                })
                gameLayer.topBar.runAction(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[currentGameColor + 1], duration: vars.colorChangeTime))
                gameLayer.bottomBar.runAction(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[currentGameColor + 1], duration: vars.colorChangeTime))
            } else {
                menuLayer.backgroundNode.runAction(colorTransitionAction(gameBGColor[currentGameColor], toColor: gameBGColor[0], duration: vars.colorChangeTime), completion: {
                    self.currentGameColor = 0
                    self.changeColor()
                })
                gameLayer.topBar.runAction(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[0], duration: vars.colorChangeTime))
                gameLayer.bottomBar.runAction(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[0], duration: vars.colorChangeTime))
            }
        }
    }
    
    func interfaceSetup() {
        menuLayer = MenuLayer()
        setColors()
        self.addChild(menuLayer)
        setHighscore()
        isColorizing = true
        changeColor()
    }
    
    func setHighscore() {
        var highscoreTime = vars.highscore.roundToPlaces(2)
        
        let minutes = UInt8(highscoreTime / 60.0)
        
        highscoreTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt8(highscoreTime)
        
        highscoreTime -= NSTimeInterval(seconds)
        
        let fraction = Int(round(highscoreTime * 100.0)) % 100
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        menuLayer.highscoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
    }
    
    func setupSpawnTimer() {
        if spawnTimerRunning == false {
            spawnTimerRunning = true
            self.spawnTimer = NSTimer.scheduledTimerWithTimeInterval(vars.timerWait, target: self, selector: Selector("updateSpawnTimer"), userInfo: nil, repeats: true)
        }
    }
    
    override func screenInteractionStarted(location: CGPoint) {
        if self.nodeAtPoint(location) == menuLayer.playButton {
            lastNodeName = menuLayer.playButton.name!
            menuLayer.playButton.runAction(fadeColorAction, withKey: "fade")
        } else if self.nodeAtPoint(location) == menuLayer.GCNode {
            lastNodeName = menuLayer.GCNode.name!
            menuLayer.GCNode.runAction(fadeColorAction, withKey: "fade")
        } else if self.nodeAtPoint(location) == highscoreLayer.highscoreNode || self.nodeAtPoint(location) == highscoreLayer.highscoreText {
            if gameRestarting == false {
                lastNodeName = highscoreLayer.highscoreNode.name!
                highscoreLayer.highscoreNode.runAction(fadeColorAction, withKey: "fade")
            }
        } else if self.nodeAtPoint(location) == highscoreLayer.shareNode {
            lastNodeName = highscoreLayer.shareNode.name!
            highscoreLayer.shareNode.runAction(fadeColorAction, withKey: "fade")
        } else {
            if location.x >= vars.screenSize.width / 2 {
                moveLeft = false
                moveRight = true
            } else if location.x <= vars.screenSize.width / 2 {
                moveRight = false
                moveLeft = true
            }
        }
    }
    
    func removeNodeAction() {
        menuLayer.playButton.removeActionForKey("fade")
        menuLayer.GCNode.removeActionForKey("fade")
        highscoreLayer.shareNode.removeActionForKey("fade")
        highscoreLayer.highscoreNode.removeActionForKey("fade")
        menuLayer.playButton.runAction(fadeOutColorAction)
        menuLayer.GCNode.runAction(fadeOutColorAction)
        highscoreLayer.shareNode.runAction(fadeOutColorAction)
        highscoreLayer.highscoreNode.runAction(fadeOutColorAction)
        moveRight = false
        moveLeft = false
    }
    
    override func screenInteractionMoved(location: CGPoint) {
        if vars.currentGameState == .gameActive {
            if lastNodeName == "" {
                if location.x >= vars.screenSize.width / 2 {
                    moveLeft = false
                    moveRight = true
                } else if location.x <= vars.screenSize.width / 2 {
                    moveRight = false
                    moveLeft = true
                }
            }
        }
    }
    
    func restartButton() {
        highscoreLayer.highscoreNode.runAction(SKAction.fadeOutWithDuration(0.5))
        highscoreLayer.highscoreText.runAction(SKAction.fadeOutWithDuration(0.5))
        highscoreLayer.shareNode.runAction(SKAction.fadeOutWithDuration(0.5))
        menuLayer.GCNode.runAction(SKAction.fadeOutWithDuration(0.5), completion: {
            self.menuLayer.GCNode.hidden = true
            self.highscoreLayer.removeFromParent()
            self.menuLayer.highscoreNode.runAction(SKAction.moveToY(self.menuLayer.highscoreNode.position.y - vars.screenSize.height / 8, duration: 0.5))
            self.gameLayer.player.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
            self.gameLayer.player.runAction(SKAction.fadeInWithDuration(0.5))
            self.gameLayer.scoreNode.runAction(SKAction.moveToY(self.gameLayer.scoreNode.position.y - vars.screenSize.height / 8, duration: 0.5), completion: {
                self.restartGame()
                self.gameRestarting = false
            })
        })
    }
    
    override func screenInteractionEnded(location: CGPoint) {
        
        if self.nodeAtPoint(location) == menuLayer.playButton {
            if gameStarted == false {
                gameStarted = true
                if lastNodeName == menuLayer.playButton.name {
                    lastNodeName = ""
                    menuLayer.playButton.runAction(fadeOutColorAction, withKey: "fade")
                    showGameLayer()
                } else {
                    removeNodeAction()
                }
            }
        } else if self.nodeAtPoint(location) == menuLayer.GCNode {
            if lastNodeName == menuLayer.GCNode.name {
                lastNodeName = ""
                menuLayer.GCNode.runAction(fadeOutColorAction, withKey: "fade")
                if vars.currentGameState == .gameOver || vars.currentGameState == .gameMenu {
                    EGC.showGameCenterLeaderboard(leaderboardIdentifier: "IdentifierLeaderboard")
                }
            } else {
                removeNodeAction()
            }
        } else if self.nodeAtPoint(location) == highscoreLayer.highscoreNode {
            if gameRestarting == false {
                gameRestarting = true
                if lastNodeName == highscoreLayer.highscoreNode.name {
                    lastNodeName = ""
                    highscoreLayer.highscoreNode.runAction(fadeOutColorAction, withKey: "fade")
                    restartButton()
                }
            } else {
                removeNodeAction()
            }
        } else if self.nodeAtPoint(location) == highscoreLayer.shareNode {
            if lastNodeName == highscoreLayer.shareNode.name {
                lastNodeName = ""
                highscoreLayer.shareNode.runAction(fadeOutColorAction, withKey: "fade")
                NSNotificationCenter.defaultCenter().postNotificationName("shareHighscore", object: nil)
            } else {
                removeNodeAction()
            }
        } else {
            removeNodeAction()
        }
    }
    
    func startTimerAfter() {
        if vars.currentGameState == .gameActive {
            if timerRunning == false {
                timerRunning = true
                let aSelector : Selector = "updateTime"
                setupSpawnTimer()
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
                let newTime:NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
                startTime = newTime - (stopTime - startTime)
            }
        }
    }
    
    func startTimer() {
        if timerRunning == false {
            timerRunning = true
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        timerRunning = false
    }
    
    func stopTimerAfter() {
        stopTime = NSDate.timeIntervalSinceReferenceDate()
        timer.invalidate()
        spawnTimer.invalidate()
        timerRunning = false
    }
    
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        currentScore = elapsedTime
        if currentScore > vars.highscore {
            newHighscore = true
            vars.highscore = (round(100 * currentScore) / 100)
        }
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        if achievements.fiveSeconds == false {
            if seconds >= 5 {
                achievements.fiveSeconds = true
                //EGC.reportAchievement(progress: 100.00, achievementIdentifier: "name", showBannnerIfCompleted: true, addToExisting: false)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fiveSeconds")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        if achievements.tenSeconds == false {
            if seconds >= 10 {
                achievements.tenSeconds = true
                //EGC.reportAchievement(progress: 100.00, achievementIdentifier: "name", showBannnerIfCompleted: true, addToExisting: false)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "tenSeconds")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        if achievements.twentySeconds == false {
            if seconds >= 20 {
                achievements.twentySeconds = true
                //EGC.reportAchievement(progress: 100.00, achievementIdentifier: "name", showBannnerIfCompleted: true, addToExisting: false)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "twentySeconds")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        if achievements.thirtySeconds == false {
            if seconds >= 30 {
                achievements.thirtySeconds = true
                //EGC.reportAchievement(progress: 100.00, achievementIdentifier: "name", showBannnerIfCompleted: true, addToExisting: false)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "thirtySeconds")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        if achievements.oneMinute == false {
            if minutes >= 1 {
                achievements.oneMinute = true
                //EGC.reportAchievement(progress: 100.00, achievementIdentifier: "name", showBannnerIfCompleted: true, addToExisting: false)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "oneMinute")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        if achievements.oneHour == false {
            if minutes >= 59 && seconds >= 59 && fraction >= 59 {
                achievements.oneHour = true
                //EGC.reportAchievement(progress: 100.00, achievementIdentifier: "name", showBannnerIfCompleted: true, addToExisting: false)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "oneHour")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        
        gameLayer.scoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
        if newHighscore == true {
            menuLayer.highscoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
        }
        
    }
    
    func showGameLayer() {
        gameLayer = GameLayer()
        setColors()
        addChild(gameLayer)
        barsFadedIn = false
        
        menuLayer.GCNode.runAction(SKAction.fadeOutWithDuration(vars.gameLayerFadeTime), completion:  {
            self.menuLayer.GCNode.hidden = true
        })
        gameLayer.topBar.runAction(gameLayer.topBarInAction)
        gameLayer.bottomBar.runAction(gameLayer.bottomBarInAction)
        gameLayer.scoreNode.runAction(gameLayer.scoreNodeInAction)
        menuLayer.playButton.runAction(SKAction.scaleTo(0.3, duration: vars.gameLayerFadeTime), completion: {
            self.menuLayer.playButton.hidden = true
            self.setupPhysics()
            vars.currentGameState = .gameActive
            self.setupSpawnTimer()
            self.barsFadedIn = false
            self.objectsCanRotate = true
            self.startTimer()
        })
    }
    
    func updateSpawnTimer() {
        getSpawnPositions()
    }
    
    func splitedString(string: String, length: Int) -> [String] {
        var result = [String]()
        
        for var i = 0; i < string.characters.count; i += length {
            let endIndex = string.endIndex.advancedBy(-i)
            let startIndex = endIndex.advancedBy(-length, limit: string.startIndex)
            result.append(string[startIndex..<endIndex])
        }
        
        return result.reverse()
    }
    
    func setupPhysics() {
        gameLayer.topBar.physicsBody = SKPhysicsBody(rectangleOfSize: gameLayer.topBar.frame.size)
        gameLayer.topBar.physicsBody!.affectedByGravity = false
        gameLayer.topBar.physicsBody!.categoryBitMask = ColliderType.Ground.rawValue
        gameLayer.topBar.physicsBody!.contactTestBitMask = ColliderType.Player.rawValue
        gameLayer.topBar.physicsBody!.collisionBitMask = ColliderType.Player.rawValue
        gameLayer.topBar.physicsBody!.allowsRotation = false
        gameLayer.topBar.physicsBody!.dynamic = false
        
        gameLayer.bottomBar.physicsBody = SKPhysicsBody(rectangleOfSize: gameLayer.bottomBar.frame.size)
        gameLayer.bottomBar.physicsBody!.affectedByGravity = false
        gameLayer.bottomBar.physicsBody!.categoryBitMask = ColliderType.Ground.rawValue
        gameLayer.bottomBar.physicsBody!.contactTestBitMask = ColliderType.Player.rawValue
        gameLayer.bottomBar.physicsBody!.collisionBitMask = ColliderType.Player.rawValue
        gameLayer.bottomBar.physicsBody!.allowsRotation = false
        gameLayer.bottomBar.physicsBody!.dynamic = false
        
        gameLayer.player.physicsBody = SKPhysicsBody(circleOfRadius: gameLayer.player.frame.size.height / 2.5)
        gameLayer.player.physicsBody!.affectedByGravity = true
        gameLayer.player.physicsBody!.categoryBitMask = ColliderType.Player.rawValue
        gameLayer.player.physicsBody!.contactTestBitMask = ColliderType.Ground.rawValue | ColliderType.Objects.rawValue
        gameLayer.player.physicsBody!.collisionBitMask = ColliderType.Ground.rawValue | ColliderType.Objects.rawValue
        gameLayer.player.physicsBody!.allowsRotation = false
    }
    
    func switchGravity() {
        if gravityDirection == "down" {
            gravityDirection = "up"
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: vars.gravity)
        } else if gravityDirection == "up" {
            gravityDirection = "down"
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -vars.gravity)
        }
    }
    
    func getSpawnPositions() {
        var objectCount:Int = Int(arc4random_uniform(3))
        objectCount += 1
        let objectSide:Int = Int(arc4random_uniform(2))
        var objectSpawnPoints:[CGFloat] = []
        let gameSizeY:CGFloat = vars.screenSize.height - vars.barHeight * 2
        let spawnSpace:CGFloat = gameSizeY / 4
        
        objectSpawnPoints.append(vars.barHeight + spawnSpace)
        objectSpawnPoints.append(vars.barHeight + spawnSpace * 2)
        objectSpawnPoints.append(vars.barHeight + spawnSpace * 3)
        
        //Spawning
        
        if objectCount == 1 {
            let whichSpawn:Int =  Int(arc4random_uniform(3))
            if objectSide == 0 {
                createObjects(CGPoint(x: vars.screenOutLeft, y: objectSpawnPoints[whichSpawn]), direction: "right")
            } else if objectSide == 1 {
                createObjects(CGPoint(x: vars.screenOutRight, y: objectSpawnPoints[whichSpawn]), direction: "left")
            }
        } else if objectCount == 2 {
            let whichSpawn:Int = Int(arc4random_uniform(3))
            objectSpawnPoints.removeAtIndex(whichSpawn)
            for var i = 0; i < objectSpawnPoints.count; i++ {
                if objectSide == 0 {
                    createObjects(CGPoint(x: vars.screenOutLeft, y: objectSpawnPoints[i]), direction: "right")
                } else if objectSide == 1 {
                    createObjects(CGPoint(x: vars.screenOutRight, y: objectSpawnPoints[i]), direction: "left")
                }
            }
        } else if objectCount == 3 {
            for var i = 0; i < objectCount; i++ {
                if objectSide == 0 {
                    createObjects(CGPoint(x: vars.screenOutLeft, y: objectSpawnPoints[i]), direction: "right")
                } else if objectSide == 1 {
                    createObjects(CGPoint(x: vars.screenOutRight, y: objectSpawnPoints[i]), direction: "left")
                }
            }
        }
    }
    
    func createObjects(location : CGPoint, direction: String) {
        let object = SKShapeNode(rectOfSize: CGSize(width: vars.objectSize, height: vars.objectSize), cornerRadius: 3)
        object.position = location
        object.zPosition = 3
        object.fillColor = gameBGColor[currentGameColor]
        object.strokeColor = gameObjectColor[currentGameColor]
        object.lineWidth = 4
        if location.x == vars.screenOutLeft {
            object.name = "objectNeg"
        } else {
            object.name = "objectPos"
        }
        addChild(object)
        if direction == "right" {
            object.runAction(moveRightAction, completion: {
                object.removeAllActions()
                object.removeFromParent()
            })
        } else if direction == "left" {
            object.runAction(moveLeftAction, completion: {
                object.removeAllActions()
                object.removeFromParent()
            })
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            
        case ColliderType.Player.rawValue | ColliderType.Objects.rawValue:
            contact.bodyA.dynamic = false
            contact.bodyB.dynamic = false
            gameOver()
            
        case ColliderType.Player.rawValue | ColliderType.Ground.rawValue:
            switchGravity()
            
        default:
            print("unknown collision")
        }
    }
    
    func setColors() {
        menuLayer.backgroundNode.fillColor = gameBGColor[currentGameColor]
        menuLayer.backgroundNode.strokeColor = gameBGColor[currentGameColor]
        gameLayer.topBar.fillColor = gameObjectColor[currentGameColor]
        gameLayer.topBar.strokeColor = gameObjectColor[currentGameColor]
        gameLayer.bottomBar.fillColor = gameObjectColor[currentGameColor]
        gameLayer.bottomBar.strokeColor = gameObjectColor[currentGameColor]
    }
    
    func gotNewHighscore() {
        vars.highscore = vars.highscore.roundToPlaces(2)
        NSUserDefaults.standardUserDefaults().setDouble(vars.highscore, forKey: "highscore")
        NSUserDefaults.standardUserDefaults().synchronize()
        EGC.reportScoreLeaderboard(leaderboardIdentifier: "gravity_leaderboard", score: Int(vars.highscore * 100))
        openNewHighScore()
    }
    
    func openNewHighScore() {
        highscoreLayer = HighscoreLayer()
        self.addChild(highscoreLayer)
        
        gameLayer.scoreNode.runAction(SKAction.moveToY(gameLayer.scoreNode.position.y + vars.screenSize.height / 8, duration: 0.5))
        menuLayer.highscoreNode.runAction(SKAction.moveToY(menuLayer.highscoreNode.position.y + vars.screenSize.height / 8, duration: 0.5), completion: {
            self.menuLayer.GCNode.hidden = false
            self.menuLayer.GCNode.runAction(SKAction.fadeInWithDuration(0.5))
            self.highscoreLayer.shareNode.runAction(SKAction.fadeInWithDuration(0.5))
        })
        gameLayer.player.runAction(SKAction.fadeOutWithDuration(0.5), completion: {
            self.highscoreLayer.highscoreText.fontColor = self.gameLayer.topBar.fillColor
            self.highscoreLayer.highscoreText.text = self.menuLayer.highscoreNode.text
            self.highscoreLayer.highscoreNode.runAction(SKAction.fadeInWithDuration(1))
            self.highscoreLayer.highscoreText.runAction(SKAction.fadeInWithDuration(1))
        })
    }
    
    func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat
    {
        return (b-a) * fraction + a
    }
    
    func colorTransitionAction(fromColor : UIColor, toColor : UIColor, duration : Double = 1.0) -> SKAction {
        var fr = CGFloat(0.0)
        var fg = CGFloat(0.0)
        var fb = CGFloat(0.0)
        var fa = CGFloat(0.0)
        var tr = CGFloat(0.0)
        var tg = CGFloat(0.0)
        var tb = CGFloat(0.0)
        var ta = CGFloat(0.0)
        
        fromColor.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        toColor.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
        
        return SKAction.customActionWithDuration(duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let transColor = UIColor(red: self.lerp(fr, b: tr, fraction: fraction),
                green: self.lerp(fg, b: tg, fraction: fraction),
                blue: self.lerp(fb, b: tb, fraction: fraction),
                alpha: self.lerp(fa, b: ta, fraction: fraction))
            (node as! SKShapeNode).fillColor = transColor
            (node as! SKShapeNode).strokeColor = transColor
            }
        )
    }
    
    func gameOver() {
        spawnTimer.invalidate()
        gameLayer.player.physicsBody?.affectedByGravity = false
        gameLayer.player.physicsBody?.dynamic = false
        gameLayer.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        stopTimer()
        objectsCanRotate = false
        spawnTimerRunning = false
        vars.gamesPlayed += 1
        NSUserDefaults.standardUserDefaults().setInteger(vars.gamesPlayed, forKey: "gamesPlayed")
        NSUserDefaults.standardUserDefaults().synchronize()
        print(vars.gamesPlayed)
        EGC.reportScoreLeaderboard(leaderboardIdentifier: "gravity_timesplayed", score: vars.gamesPlayed)
        self.enumerateChildNodesWithName("objectPos") {
            node, stop in
            node.removeAllActions()
            self.objectMoveRightAction = SKAction.moveToX(node.position.x + vars.screenSize.width, duration: 0.5)
            self.objectMoveRightAction.timingMode = .Linear
            self.objectMoveLeftAction = SKAction.moveToX(node.position.x - vars.screenSize.width, duration: 0.5)
            self.objectMoveLeftAction.timingMode = .Linear
            node.runAction(self.waitAction, completion: {
                self.objectsCanRotate = true
            })
            node.runAction(SKAction.sequence([
                self.waitAction,
                self.objectMoveLeftAction
                ]), completion: {
                    node.removeFromParent()
            })
        }
        self.enumerateChildNodesWithName("objectNeg") {
            node, stop in
            node.removeAllActions()
            self.objectMoveRightAction = SKAction.moveToX(node.position.x + vars.screenSize.width, duration: 0.5)
            self.objectMoveRightAction.timingMode = .Linear
            self.objectMoveLeftAction = SKAction.moveToX(node.position.x - vars.screenSize.width, duration: 0.5)
            self.objectMoveLeftAction.timingMode = .Linear
            node.runAction(self.waitAction, completion: {
                self.objectsCanRotate = true
            })
            node.runAction(SKAction.sequence([
                self.waitAction,
                self.objectMoveRightAction
                ]), completion: {
                    node.removeFromParent()
            })
        }
        vars.currentGameState = .gameOver
        if newHighscore == true {
            gameLayer.player.runAction(SKAction.sequence([
                SKAction.fadeOutWithDuration(0.5),
                ]), completion: {
                    self.gotNewHighscore()
                })
            newHighscore = false
        } else {
            newHighscore = false
            gameLayer.player.runAction(SKAction.sequence([
                self.waitAction,
                SKAction.scaleTo(0, duration: 0.3),
                SKAction.waitForDuration(0.2)
                ]), completion: {
                    self.gameLayer.player.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
                    self.gameLayer.player.alpha = 1
                    self.gameLayer.player.runAction(SKAction.scaleTo(1, duration: 0.3), completion: {
                        self.restartGame()
                    })
            })
        }
    }
    
    func restartGame() {
        vars.currentGameState = .gameActive
        objectsCanRotate = true
        objectRotationPos = 0
        objectRotationNeg = 360
        gameLayer.scoreNode.text = "00:00:00"
        startTimer()
        setupSpawnTimer()
        gameLayer.player.physicsBody?.affectedByGravity = true
        gameLayer.player.physicsBody?.dynamic = true
        gravityDirection = "up"
        switchGravity()
    }
    
    func colorizeBars() {
        let myColor = menuLayer.backgroundNode.strokeColor
        if let myCIColor = myColor.coreImageColor {
            let redColor:CGFloat = myCIColor.red
            let greenColor:CGFloat = myCIColor.green
            let blueColor:CGFloat = myCIColor.blue
            let alphaColor:CGFloat = myCIColor.alpha
            let newColor = SKColor(red: redColor - (30 / 255), green: greenColor - (30 / 255), blue: blueColor - (30 / 255), alpha: alphaColor)
            gameLayer.topBar.strokeColor = newColor
            gameLayer.topBar.fillColor = newColor
            gameLayer.bottomBar.strokeColor = newColor
            gameLayer.bottomBar.fillColor = newColor
        }
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        self.enumerateChildNodesWithName("objectPos") {
            node, stop in
            (node as! SKShapeNode).fillColor = self.menuLayer.backgroundNode.fillColor
            (node as! SKShapeNode).strokeColor = self.gameLayer.topBar.strokeColor
            if node.position.x < vars.screenSize.width && node.physicsBody == nil {
                node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: vars.objectSize, height: vars.objectSize))
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.categoryBitMask = ColliderType.Objects.rawValue
                node.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue
                node.physicsBody?.collisionBitMask = ColliderType.Player.rawValue
                node.physicsBody?.dynamic = false
                node.physicsBody?.allowsRotation = false
            }
            if self.objectsCanRotate == true {
                (node as! SKShapeNode).zRotation = self.objectRotationPos.degreesToRadians
            }
        }
        self.enumerateChildNodesWithName("objectNeg") {
            node, stop in
            (node as! SKShapeNode).fillColor = self.menuLayer.backgroundNode.fillColor
            (node as! SKShapeNode).strokeColor = self.gameLayer.topBar.strokeColor
            if node.position.x > 0 && node.physicsBody == nil {
                node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: vars.objectSize, height: vars.objectSize))
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.categoryBitMask = ColliderType.Objects.rawValue
                node.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue
                node.physicsBody?.collisionBitMask = ColliderType.Player.rawValue
                node.physicsBody?.dynamic = false
                node.physicsBody?.allowsRotation = false
            }
            if self.objectsCanRotate == true {
                (node as! SKShapeNode).zRotation = self.objectRotationNeg.degreesToRadians
            }
        }
        if objectsCanRotate == true {
            if vars.currentGameState == .gameOver {
                if objectRotationPos < 360 {
                    objectRotationPos += 5
                } else {
                    objectRotationPos = 0
                }
                if objectRotationNeg > 0 {
                    objectRotationNeg -= 5
                } else {
                    objectRotationNeg = 360
                }
            } else {
                if objectRotationPos < 360 {
                    objectRotationPos += 1
                } else {
                    objectRotationPos = 0
                }
                if objectRotationNeg > 0 {
                    objectRotationNeg -= 1
                } else {
                    objectRotationNeg = 360
                }
            }
        }
        if barsFadedIn == false {
            colorizeBars()
        }
        if vars.currentGameState == .gameOver {
            highscoreLayer.highscoreText.fontColor = gameLayer.topBar.strokeColor
        }
        if vars.currentGameState == .gameActive {
            if moveRight == true {
                gameLayer.player.position.x += vars.playerSideSpeed
                if gameLayer.player.position.x >= vars.screenSize.width {
                    gameLayer.player.position.x = 0
                }
            } else if moveLeft == true {
                gameLayer.player.position.x -= vars.playerSideSpeed
                if gameLayer.player.position.x <= 0 {
                    gameLayer.player.position.x = vars.screenSize.width
                }
            }
        }
        if gameCenterSync == false {
            if vars.gameCenterLoggedIn == true {
                gameCenterSync = true
                setHighscore()
            }
        }
    }
}
extension UIColor {
    var coreImageColor: CoreImage.CIColor? {
        return CoreImage.CIColor(color: self)
    }
}
extension Double {
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
extension Int {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}