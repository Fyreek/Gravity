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
    enum gameState {
        case gameMenu
        case gameOver
        case gameActive
    }
    
    enum ColliderType:UInt32 {
        case All = 0xFFFFFFFF
        case Player = 0b001
        case Ground = 0b010
        case Objects = 0b100
    }
    
    //Layers
    var menuLayer = MenuLayer()
    var gameLayer = GameLayer()
    var highScoreLayer = HighScoreLayer()
    
    //Vars
    var lastNodeName = ""
    var gravityDirection = "down"
    var currentGameState:gameState = .gameMenu
    var moveLeft:Bool = false
    var moveRight:Bool = false
    var spawnTimer = NSTimer()
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    var currentScore: NSTimeInterval = 0
    var highScore: NSTimeInterval = 0
    var newHighScore:Bool = false
    var gameCenterSync:Bool = false
    var gameBGColor:[SKColor] = []
    var gameObjectColor:[SKColor] = []
    var currentGameColor:Int = 0
    var isColorizing:Bool = false
    
    //Actions
    var colorizeBGNodes = SKAction()
    var colorizeObjectNodes = SKAction()
    let fadeColorAction = SKAction.customActionWithDuration(0.2, actionBlock: {(node: SKNode!, elapsedTime: CGFloat) -> Void in
        if node is SKSpriteNode  {
            (node as! SKSpriteNode)
        } else if node is SKShapeNode {
            (node as! SKShapeNode).fillColor = SKColor.whiteColor()
            (node as! SKShapeNode).strokeColor = SKColor.whiteColor()
        }
    })
    let fadeOutColorAction = SKAction.customActionWithDuration(0.2, actionBlock: {(node: SKNode!, elapsedTime: CGFloat) -> Void in
        if node is SKSpriteNode  {
            (node as! SKSpriteNode)
        } else if node is SKShapeNode {
            (node as! SKShapeNode).fillColor = SKColor.whiteColor()
            (node as! SKShapeNode).strokeColor = SKColor.whiteColor()
        }
    })
    
    var waitAction:SKAction = SKAction()
    var moveLeftAction:SKAction = SKAction()
    var moveRightAction:SKAction = SKAction()
    
    //Functions
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        loadValues()
        interfaceSetup()
    }
    
    func loadValues() {
        vars.screenSize = (view?.frame.size)!
        vars.barHeight = vars.screenSize.height / 7
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
        
        waitAction = SKAction.waitForDuration(vars.objectWait)
        moveLeftAction = SKAction.sequence([
            waitAction,
            SKAction.moveToX(vars.screenOutLeft, duration: vars.objectMoveTime)
        ])
        moveRightAction = SKAction.sequence([
                waitAction,
            SKAction.moveToX(vars.screenOutRight, duration: vars.objectMoveTime)
        ])
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("highScore") {
            highScore = NSTimeInterval(NSUserDefaults.standardUserDefaults().integerForKey("highScore"))
        } else {
            highScore = 0
        }
    }
    
    func changeColor() {
        
        if isColorizing == true {
            if currentGameColor <= gameBGColor.count - 2 {
                menuLayer.backgroundNode.runAction(colorTransitionAction(gameBGColor[currentGameColor], toColor: gameBGColor[currentGameColor + 1], duration: vars.colorChangeTime))
                gameLayer.topBar.runAction(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[currentGameColor + 1], duration: vars.colorChangeTime))
                gameLayer.bottomBar.runAction(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[currentGameColor + 1], duration: vars.colorChangeTime), completion: {
                    self.currentGameColor += 1
                    self.changeColor()
                })
            } else {
                menuLayer.backgroundNode.runAction(colorTransitionAction(gameBGColor[currentGameColor], toColor: gameBGColor[0], duration: vars.colorChangeTime))
                gameLayer.topBar.runAction(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[0], duration: vars.colorChangeTime))
                gameLayer.bottomBar.runAction(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[0], duration: vars.colorChangeTime), completion: {
                    self.currentGameColor = 0
                    self.changeColor()
                })
            }
        }
    }
    
    func interfaceSetup() {
        menuLayer = MenuLayer()
        setColors()
        self.addChild(menuLayer)
        setHighScore()
    }
    
    func setHighScore() {
        var highScoreTime = highScore
        let minutes = UInt8(highScoreTime / 60.0)
        
        highScoreTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt8(highScoreTime)
        
        highScoreTime -= NSTimeInterval(seconds)
        
        let fraction = UInt8(highScoreTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        menuLayer.highScoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
    }
    
    func setupSpawnTimer() {
        self.spawnTimer = NSTimer.scheduledTimerWithTimeInterval(vars.timerWait, target: self, selector: Selector("updateSpawnTimer"), userInfo: nil, repeats: true)
    }
    
    override func screenInteractionStarted(location: CGPoint) {
        if self.nodeAtPoint(location) == menuLayer.playButton {
            lastNodeName = menuLayer.playButton.name!
            menuLayer.playButton.runAction(fadeColorAction)
        } else if self.nodeAtPoint(location) == menuLayer.GCNode {
            lastNodeName = menuLayer.GCNode.name!
            menuLayer.GCNode.runAction(fadeColorAction)
        } else if self.nodeAtPoint(location) == highScoreLayer.highScoreNode || self.nodeAtPoint(location) == highScoreLayer.highScoreText {
            lastNodeName = highScoreLayer.highScoreNode.name!
            highScoreLayer.highScoreNode.runAction(fadeColorAction)
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
        menuLayer.playButton.removeAllActions()
        menuLayer.GCNode.removeAllActions()
        menuLayer.playButton.runAction(fadeOutColorAction)
        menuLayer.GCNode.runAction(fadeOutColorAction)
        moveRight = false
        moveLeft = false
    }
    
    override func screenInteractionMoved(location: CGPoint) {
        if currentGameState == .gameActive {
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
    
    override func screenInteractionEnded(location: CGPoint) {
        if self.nodeAtPoint(location) == menuLayer.playButton || self.nodeAtPoint(location) == menuLayer.GCNode || self.nodeAtPoint(location) == highScoreLayer.highScoreNode{
            if lastNodeName == menuLayer.playButton.name {
                lastNodeName = ""
                menuLayer.playButton.runAction(fadeOutColorAction)
                showGameLayer()
            } else if lastNodeName == menuLayer.GCNode.name {
                lastNodeName = ""
                menuLayer.GCNode.runAction(fadeOutColorAction)
                EGC.showGameCenterLeaderboard(leaderboardIdentifier: "IdentifierLeaderboard")
            } else if lastNodeName == highScoreLayer.highScoreNode.name {
                highScoreLayer.highScoreNode.runAction(SKAction.fadeOutWithDuration(0.5))
                highScoreLayer.highScoreText.runAction(SKAction.fadeOutWithDuration(0.5))
                highScoreLayer.shareNode.runAction(SKAction.fadeOutWithDuration(0.5))
                menuLayer.GCNode.runAction(SKAction.fadeOutWithDuration(0.5), completion: {
                self.highScoreLayer.removeFromParent()
                self.menuLayer.highScoreNode.runAction(SKAction.moveToY(self.menuLayer.highScoreNode.position.y - vars.screenSize.height / 8, duration: 0.5))
                    self.gameLayer.player.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
                    self.gameLayer.player.runAction(SKAction.fadeInWithDuration(0.5))
                    self.gameLayer.scoreNode.runAction(SKAction.moveToY(self.gameLayer.scoreNode.position.y - vars.screenSize.height / 8, duration: 0.5), completion: {
                        self.restartGame()
                    })
                })
            } else {
                removeNodeAction()
            }
        } else {
            removeNodeAction()
        }
    }
    
    func startTimer() {
        let aSelector : Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func stopTimer(){
        timer.invalidate()
    }
    
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        currentScore = elapsedTime
        if currentScore > highScore {
            newHighScore = true
            highScore = currentScore
        }
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        gameLayer.scoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
        if newHighScore == true {
            menuLayer.highScoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
        }
        
    }
    
    func showGameLayer() {
        gameLayer = GameLayer()
        setColors()
        addChild(gameLayer)
        
        menuLayer.GCNode.runAction(SKAction.fadeOutWithDuration(vars.gameLayerFadeTime))
        gameLayer.topBar.runAction(gameLayer.topBarInAction)
        gameLayer.bottomBar.runAction(gameLayer.bottomBarInAction)
        gameLayer.scoreNode.runAction(gameLayer.scoreNodeInAction)
        menuLayer.playButton.runAction(SKAction.scaleTo(0.5, duration: vars.gameLayerFadeTime), completion: {
            self.menuLayer.playButton.hidden = true
            self.setupPhysics()
            self.currentGameState = .gameActive
            self.setupSpawnTimer()
            self.startTimer()
            self.isColorizing = true
            self.changeColor()
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
        let object = SKShapeNode(rectOfSize: CGSize(width: vars.objectSize, height: vars.objectSize))
        object.position = location
        object.zPosition = 3
        object.fillColor = gameObjectColor[currentGameColor]
        object.strokeColor = gameObjectColor[currentGameColor]
        object.name = "object"
        object.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: vars.objectSize, height: vars.objectSize))
        object.physicsBody?.affectedByGravity = false
        object.physicsBody?.categoryBitMask = ColliderType.Objects.rawValue
        object.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue
        object.physicsBody?.collisionBitMask = ColliderType.Player.rawValue
        object.physicsBody?.dynamic = false
        object.physicsBody?.allowsRotation = false
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
            
        case ColliderType.Player.rawValue | ColliderType.Ground.rawValue:
            switchGravity()
            
        case ColliderType.Player.rawValue | ColliderType.Objects.rawValue:
            gameOver()
        default:
            print("unkown collision")
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
    
    func gotNewHighScore() {
        NSUserDefaults.standardUserDefaults().setInteger(Int(highScore), forKey: "highScore")
        NSUserDefaults.standardUserDefaults().synchronize()
        EGC.reportScoreLeaderboard(leaderboardIdentifier: "gravity_leaderboard", score: Int(highScore))
        openNewHighScore()
    }
    
    func openNewHighScore() {
        highScoreLayer = HighScoreLayer()
        self.addChild(highScoreLayer)
        
        gameLayer.scoreNode.runAction(SKAction.moveToY(gameLayer.scoreNode.position.y + vars.screenSize.height / 8, duration: 0.5))
        menuLayer.highScoreNode.runAction(SKAction.moveToY(menuLayer.highScoreNode.position.y + vars.screenSize.height / 8, duration: 0.5), completion: {
            self.menuLayer.GCNode.runAction(SKAction.fadeInWithDuration(0.5))
            self.highScoreLayer.shareNode.runAction(SKAction.fadeInWithDuration(0.5))
        })
        gameLayer.player.runAction(SKAction.fadeOutWithDuration(0.5), completion: {
            self.highScoreLayer.highScoreText.fontColor = self.gameObjectColor[self.currentGameColor]
            self.highScoreLayer.highScoreText.text = self.menuLayer.highScoreNode.text
            self.highScoreLayer.highScoreNode.runAction(SKAction.fadeInWithDuration(1))
            self.highScoreLayer.highScoreText.runAction(SKAction.fadeInWithDuration(1))
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
        self.enumerateChildNodesWithName("object") {
            node, stop in
            node.removeAllActions()
            node.runAction(SKAction.sequence([
                self.waitAction,
                SKAction.fadeOutWithDuration(vars.objectFadeOutDuration)
            ]), completion: {
                node.removeFromParent()
            })
        }
        currentGameState = .gameOver
        isColorizing = false
        stopTimer()
        if newHighScore == true {
            gotNewHighScore()
            newHighScore = false
        } else {
            newHighScore = false
            gameLayer.player.runAction(SKAction.sequence([
                self.waitAction,
                SKAction.moveTo(CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2), duration: vars.objectFadeOutDuration)
                ]), completion: {
                    self.restartGame()
            })
        }
    }
    
    func restartGame() {
        currentGameState = .gameActive
        gameLayer.scoreNode.text = "00:00:00"
        startTimer()
        setupSpawnTimer()
        gameLayer.player.physicsBody?.affectedByGravity = true
        gameLayer.player.physicsBody?.dynamic = true
        gravityDirection = "up"
        switchGravity()
        isColorizing = true
        changeColor()
    }
    
    override func update(currentTime: CFTimeInterval) {
        if currentGameState == .gameActive {
            self.enumerateChildNodesWithName("object") {
                node, stop in
                (node as! SKShapeNode).fillColor = self.gameLayer.topBar.fillColor
                (node as! SKShapeNode).strokeColor = self.gameLayer.topBar.strokeColor
            }
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
            gameCenterSync = true
            if vars.gameCenterLoggedIn == true {
                if NSTimeInterval(vars.highScore) > highScore {
                    highScore = NSTimeInterval(vars.highScore)
                    NSUserDefaults.standardUserDefaults().setInteger(Int(highScore), forKey: "highScore")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    setHighScore()
                } else {
                    EGC.reportScoreLeaderboard(leaderboardIdentifier: "gravity_leaderboard", score: Int(highScore * 100))
                }
            }
        }
    }
}
