//
//  GameScene.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 13/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//

import SpriteKit

class GameScene: SKSceneExtension, SKPhysicsContactDelegate {
    
    //Enums
    enum ColliderType:UInt32 {
        case all = 0xFFFFFFFF
        case player = 0b001
        case ground = 0b010
        case objects = 0b100
    }
    
    
    var viewController = NSApplication.shared().delegate as! AppDelegate
    
    //Layers
    var menuLayer = MenuLayer()
    var gameLayer = GameLayer()
    var highscoreLayer = HighscoreLayer()
    
    //Vars
    var lastNodeName = ""
    var gravityDirection = "down"
    var moveLeft:Bool = false
    var moveRight:Bool = false
    var spawnTimer = Timer()
    var timer = Timer()
    var startTime = TimeInterval()
    var stopTime = TimeInterval()
    var currentScore: TimeInterval = 0
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
    var timesPlayedWithoutInteraction:Int = 0
    var interactionHappend:Bool = false
    var isAnimating:Bool = false
    var preCursorPos:NSPoint = NSPoint(x: 0, y: 0)
    
    //Actions
    let fadeColorAction = SKAction.customAction(withDuration: 0.5, actionBlock: {(node: SKNode!, elapsedTime: CGFloat) -> Void in
        if node is SKSpriteNode  {
            (node as! SKSpriteNode).alpha = 0.8
        } else if node is SKShapeNode {
            (node as! SKShapeNode).alpha = 0.8
        }
    })
    let fadeOutColorAction = SKAction.customAction(withDuration: 0.5, actionBlock: {(node: SKNode!, elapsedTime: CGFloat) -> Void in
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
    override func didMove(to view: SKView) {
        viewController.setWindowStyleMenu()
        reloadGame()
    }
    
    func reloadGame() {
        self.physicsWorld.contactDelegate = self
        loadValues()
        loadNSUserData()
        interfaceSetup()
    }
    
    func rerangeInterface() {
        loadValues()
        if vars.currentGameState == .gameMenu {
            menuLayer.removeFromParent()
        } else if vars.currentGameState == .gameOver {
            highscoreLayer.removeFromParent()
        }
        interfaceSetup()
    }
    
    func loadValues() {
        
        vars.screenSize = (view?.frame.size)! //What size the display has
        vars.barHeight = vars.screenSize.height / 6 //How high the bars at top and bottom are - normal: / 6
        vars.objectSize = vars.screenSize.height / 36 //How big the objects are - normal: / 36
        vars.screenOutLeft = -vars.objectSize * 2 //Spawnpoint on the left side
        vars.screenOutRight = vars.screenSize.width + vars.objectSize * 2 //Spawnpoint on the right side
        
        if vars.extremeMode == false {
            initNormalMode()
        } else {
            initExtremeMode()
        }
        
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
    }
    
    func initExtremeMode() {
        setHighscore()
        vars.playerSideSpeed = vars.screenSize.width / 130 //How fast the player moves sideways - normal: / 160
        vars.gravity = vars.screenSize.height / 30 //How fast the player moves up and down - normal: / 35
        vars.objectMoveTime = 2
        vars.colorChangeTime = 0.5
        
        waitAction = SKAction.wait(forDuration: vars.objectWait)
        moveLeftAction = SKAction.sequence([
            waitAction,
            SKAction.moveTo(x: vars.screenOutLeft, duration: vars.objectMoveTime)
            ])
        moveRightAction = SKAction.sequence([
            waitAction,
            SKAction.moveTo(x: vars.screenOutRight, duration: vars.objectMoveTime)
            ])
    }
    
    func initNormalMode() {
        setHighscore()
        vars.playerSideSpeed = vars.screenSize.width / 160 //How fast the player moves sideways - normal: / 160
        vars.gravity = vars.screenSize.height / 40 //How fast the player moves up and down - normal: / 35
        vars.objectMoveTime = 4
        vars.colorChangeTime = 5
        
        waitAction = SKAction.wait(forDuration: vars.objectWait)
        moveLeftAction = SKAction.sequence([
            waitAction,
            SKAction.moveTo(x: vars.screenOutLeft, duration: vars.objectMoveTime)
            ])
        moveRightAction = SKAction.sequence([
            waitAction,
            SKAction.moveTo(x: vars.screenOutRight, duration: vars.objectMoveTime)
            ])
    }
    
    func loadNSUserData() {
        if let _ = UserDefaults.standard.object(forKey: "highscore") {
            vars.highscore = UserDefaults.standard.double(forKey: "highscore")
        } else {
            vars.highscore = 0
        }
        if let _ = UserDefaults.standard.object(forKey: "extHighscore") {
            vars.extHighscore = UserDefaults.standard.double(forKey: "extHighscore")
        } else {
            vars.extHighscore = 0
        }
        if let _ = UserDefaults.standard.object(forKey: "firstTimePlaying") {
            vars.firstTimePlaying = UserDefaults.standard.bool(forKey: "firstTimePlaying")
        } else {
            vars.firstTimePlaying = false
        }
        if let _ = UserDefaults.standard.object(forKey: "gamesPlayed") {
            vars.gamesPlayed = UserDefaults.standard.integer(forKey: "gamesPlayed")
        } else {
            vars.gamesPlayed = 0
        }
        if let _ = UserDefaults.standard.object(forKey: "fiveSeconds") {
            achievements.fiveSeconds = UserDefaults.standard.bool(forKey: "fiveSeconds")
        } else {
            achievements.fiveSeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "fifthteenSeconds") {
            achievements.fifthteenSeconds = UserDefaults.standard.bool(forKey: "fifthteenSeconds")
        } else {
            achievements.fifthteenSeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "thirtySeconds") {
            achievements.thirtySeconds = UserDefaults.standard.bool(forKey: "thirtySeconds")
        } else {
            achievements.thirtySeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "sixytSeconds") {
            achievements.sixtySeconds = UserDefaults.standard.bool(forKey: "sixtySeconds")
        } else {
            achievements.sixtySeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "onehundredtwentySeconds") {
            achievements.onehundredtwentySeconds = UserDefaults.standard.bool(forKey: "onehundredtwentySeconds")
        } else {
            achievements.onehundredtwentySeconds = false
        }
        if let _ = UserDefaults.standard.object(forKey: "pi") {
            achievements.pi = UserDefaults.standard.bool(forKey: "pi")
        } else {
            achievements.pi = false
        }
        if let _ = UserDefaults.standard.object(forKey: "newton") {
            achievements.newton = UserDefaults.standard.bool(forKey: "newton")
        } else {
            achievements.newton = false
        }
        if let _ = UserDefaults.standard.object(forKey: "musicState") {
            vars.musicState = UserDefaults.standard.bool(forKey: "musicState")
        } else {
            vars.musicState = true
        }
    }
    
    func pulsingPlayButton() {
        let factor:CGFloat = menuLayer.playButton.xScale
        let pulseUp = SKAction.scale(to: factor + 0.02, duration: 2.0)
        let pulseDown = SKAction.scale(to: factor - 0.02, duration: 2.0)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        menuLayer.playButton.run(repeatPulse, withKey: "pulse")
    }
    
    func pulsingReplayButton() {
        let factor:CGFloat = highscoreLayer.highscoreNode.xScale
        let pulseUp = SKAction.scale(to: factor + 0.02, duration: 2.0)
        let pulseDown = SKAction.scale(to: factor - 0.02, duration: 2.0)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        highscoreLayer.highscoreNode.run(repeatPulse, withKey: "pulse")
    }
    
    func changeColor() {
        if isColorizing == true {
            if currentGameColor <= gameBGColor.count - 2 {
                menuLayer.backgroundNode.run(colorTransitionAction(gameBGColor[currentGameColor], toColor: gameBGColor[currentGameColor + 1], duration: vars.colorChangeTime), completion: {
                    self.currentGameColor += 1
                    self.changeColor()
                })
                gameLayer.topBar.run(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[currentGameColor + 1], duration: vars.colorChangeTime))
                gameLayer.bottomBar.run(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[currentGameColor + 1], duration: vars.colorChangeTime))
            } else {
                menuLayer.backgroundNode.run(colorTransitionAction(gameBGColor[currentGameColor], toColor: gameBGColor[0], duration: vars.colorChangeTime), completion: {
                    self.currentGameColor = 0
                    self.changeColor()
                })
                gameLayer.topBar.run(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[0], duration: vars.colorChangeTime))
                gameLayer.bottomBar.run(colorTransitionAction(gameObjectColor[currentGameColor], toColor: gameObjectColor[0], duration: vars.colorChangeTime))
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
        pulsingPlayButton()
    }
    
    func setHighscore() {
        
        var highscoreTime:Double = 0
        if vars.extremeMode == false {
            highscoreTime = vars.highscore.roundToPlaces(2)
        } else {
            highscoreTime = vars.extHighscore.roundToPlaces(2)
        }
        
        let minutes = UInt8(highscoreTime / 60.0)
        
        highscoreTime -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(highscoreTime)
        
        highscoreTime -= TimeInterval(seconds)
        
        let fraction = Int(round(highscoreTime * 100.0)) % 100
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        menuLayer.highscoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
    }
    
    func setupSpawnTimer() {
        if spawnTimerRunning == false {
            spawnTimerRunning = true
            self.spawnTimer = Timer.scheduledTimer(timeInterval: vars.timerWait, target: self, selector: #selector(GameScene.updateSpawnTimer), userInfo: nil, repeats: true)
        }
    }
    
    override func keyDown(with theEvent: NSEvent) {
        
        if theEvent.keyCode == 123 { //Left
            moveLeft = true
            interactionHappend = true
        } else if theEvent.keyCode == 124 { //Right
            moveRight = true
            interactionHappend = true
        } else if theEvent.keyCode == 126 { //Up
            
        } else if theEvent.keyCode == 13 { //W
            
        } else if theEvent.keyCode == 49 { //Space
            interactionHappend = true
        } else if theEvent.keyCode == 0 { //A
            moveLeft = true
            interactionHappend = true
        } else if theEvent.keyCode == 2 { //S
            moveRight = true
            interactionHappend = true
        }
    }
    
    override func keyUp(with theEvent: NSEvent) {
        
        if theEvent.keyCode == 123 { //Left
            moveLeft = false
            interactionHappend = true
        } else if theEvent.keyCode == 124 { //Right
            moveRight = false
            interactionHappend = true
        } else if theEvent.keyCode == 126 { //Up
            if isAnimating == false {
                if vars.currentGameState == .gameActive || vars.currentGameState == .gameOver {
                    goToMenu()
                }
            }
        } else if theEvent.keyCode == 13 { //W
            if isAnimating == false {
                if vars.currentGameState == .gameActive || vars.currentGameState == .gameOver {
                    goToMenu()
                }
            }
        } else if theEvent.keyCode == 0 { //A
            moveLeft = false
            interactionHappend = true
        } else if theEvent.keyCode == 2 { //S
            moveRight = false
            interactionHappend = true
        } else if theEvent.keyCode == 49 { //Space
            if vars.currentGameState == .gameMenu {
                if isAnimating == false {
                    if gameStarted == false {
                        gameStarted = true
                        showGameLayer()
                    }
                }
            } else if vars.currentGameState == .gameOver {
                if isAnimating == false {
                    if gameRestarting == false {
                        gameRestarting = true
                        restartButton()
                    }
                }
            }
            interactionHappend = true
        }
    }
    
    func removeNodeAction() {
        menuLayer.playButton.removeAction(forKey: "fade")
        menuLayer.GCNode.removeAction(forKey: "fade")
        highscoreLayer.shareNode.removeAction(forKey: "fade")
        highscoreLayer.highscoreNode.removeAction(forKey: "fade")
        gameLayer.menuNode.removeAction(forKey: "fade")
        menuLayer.playButton.run(fadeOutColorAction)
        menuLayer.GCNode.run(fadeOutColorAction)
        highscoreLayer.shareNode.run(fadeOutColorAction)
        highscoreLayer.highscoreNode.run(fadeOutColorAction)
        gameLayer.menuNode.run(fadeOutColorAction)
        moveRight = false
        moveLeft = false
        if vars.currentGameState == .gameMenu {
            pulsingPlayButton()
        } else if vars.currentGameState == .gameOver {
            pulsingReplayButton()
        }
    }
    
    override func screenInteractionStarted(_ location: CGPoint) {
        
        let node = self.atPoint(location)
        if node.name != nil {
            lastNodeName = node.name!
            node.removeAction(forKey: "pulse")
            node.run(fadeColorAction, withKey: "fade")
        } else {
            if vars.motionControl == false {
                if location.x >= vars.screenSize.width / 2 {
                    interactionHappend = true
                    moveRight = true
                    moveLeft = false
                } else if location.x <= vars.screenSize.width / 2 {
                    interactionHappend = true
                    moveLeft = true
                    moveRight = false
                }
            }
        }
    }
    
    override func screenInteractionMoved(_ location: CGPoint) {
        if vars.currentGameState == .gameActive {
            if vars.motionControl == false {
                if lastNodeName == "" {
                    if location.x >= vars.screenSize.width / 2 {
                        interactionHappend = true
                        moveRight = true
                        moveLeft = false
                    } else if location.x <= vars.screenSize.width / 2 {
                        interactionHappend = true
                        moveLeft = true
                        moveRight = false
                    }
                }
            }
        }
    }
    
    func playButtonPressed() {
        if gameStarted == false {
            gameStarted = true
            showGameLayer()
        }
    }
    
    func GCNodePressed() {
        if vars.currentGameState == .gameOver || vars.currentGameState == .gameMenu {
            viewController.showLeaderboard(identifiers.OSXnormalLeaderboard)
        }
    }
    
    func highscoreNodeEndPressed() {
        if gameRestarting == false {
            gameRestarting = true
            restartButton()
        }
    }
    
    func shareNodePressed() {
        viewController.share()
    }
    
    func menuNodePressed() {
        goToMenu()
    }
    
    override func screenInteractionEnded(_ location: CGPoint) {
        
        let node = self.atPoint(location)
        if node.name != nil {
            if isAnimating == false {
                if lastNodeName == node.name! {
                    lastNodeName = ""
                    node.run(fadeOutColorAction, withKey: "fade")
                    let selector = NSSelectorFromString("\(node.name!)Pressed")
                    self.perform(selector)
                } else {
                    removeNodeAction()
                }
            }
        } else {
            if vars.motionControl == false {
                if location.x >= vars.screenSize.width / 2 {
                    interactionHappend = true
                    moveRight = false
                } else if location.x <= vars.screenSize.width / 2 {
                    interactionHappend = true
                    moveLeft = false
                }
            }
            removeNodeAction()
        }
    }
    
    func initMenuSwipe() {
        menuLayer.playButton.setScale(vars.screenSize.height / 1000)
    }
    
    func tvOSMenuSwipeLeft() {
        if vars.currentGameState == .gameMenu {
            if vars.selectedMenuItem == 0 {
                menuLayer.playButton.run(SKAction.scale(to: vars.screenSize.height / 1280, duration: vars.gameLayerFadeTime))
                menuLayer.GCNode.run(SKAction.scale(to: vars.screenSize.height / 1000, duration: vars.gameLayerFadeTime), completion: {
                    vars.selectedMenuItem = 1
                })
            }
        }
    }
    
    func tvOSMenuSwipeRight() {
        if vars.currentGameState == .gameMenu {
            if vars.selectedMenuItem == 1 {
                menuLayer.GCNode.run(SKAction.scale(to: vars.screenSize.height / 1280, duration: vars.gameLayerFadeTime))
                menuLayer.playButton.run(SKAction.scale(to: vars.screenSize.height / 1000, duration: vars.gameLayerFadeTime), completion: {
                    vars.selectedMenuItem = 0
                })
            }
        }
    }
    
    func restartButton() {
        if highscoreLayer.highscoreNode.position.x == vars.screenSize.width / 2 {
            highscoreLayer.highscoreText.run(SKAction.fadeOut(withDuration: 0.2), completion: {
                self.highscoreLayer.highscoreNode.run(SKAction.scale(to: 0, duration: 0.3))
            })
        } else {
            highscoreLayer.highscoreNode.run(SKAction.moveTo(x: vars.screenSize.width + highscoreLayer.highscoreNode.frame.size.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.highscoreText.run(SKAction.moveTo(x: vars.screenSize.width + highscoreLayer.highscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
        }
        highscoreLayer.firstHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.secondHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.thirdHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.fourthHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.fifthHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.firstHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.secondHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.thirdHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.fourthHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.fifthHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
        highscoreLayer.shareNode.run(SKAction.moveTo(y: vars.screenSize.height + highscoreLayer.shareNode.frame.height + vars.screenSize.height / 40, duration: vars.gameLayerFadeTime))
        menuLayer.GCNode.run(SKAction.moveTo(y: vars.screenSize.height + menuLayer.GCNode.frame.height + vars.screenSize.height / 40, duration: vars.gameLayerFadeTime), completion: {
            self.menuLayer.GCNode.zPosition = 1
            self.menuLayer.GCNode.position.y = vars.screenSize.height - ((vars.screenSize.height / 7) / 2)
            self.highscoreLayer.removeFromParent()
            self.menuLayer.highscoreNode.run(SKAction.moveTo(y: vars.screenSize.height - self.menuLayer.highscoreNode.frame.height / 2 - (vars.screenSize.height / 7) / 2, duration: vars.gameLayerFadeTime))
            self.gameLayer.player.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
            self.gameLayer.player.run(SKAction.fadeIn(withDuration: vars.gameLayerFadeTime))
            self.gameLayer.player.run(SKAction.scale(to: 1, duration: vars.gameLayerFadeTime))
            self.gameLayer.scoreNode.run(SKAction.moveTo(y: vars.screenSize.height - self.gameLayer.scoreNode.frame.height / 2 - (vars.screenSize.height / 7) / 2, duration: vars.gameLayerFadeTime), completion: {
                self.restartGame()
                self.gameRestarting = false
            })
        })
    }
    
    func goToMenu() {
        isAnimating = true
        timesPlayedWithoutInteraction = 0
        spawnTimer.invalidate()
        gameLayer.player.physicsBody?.affectedByGravity = false
        gameLayer.player.physicsBody?.isDynamic = false
        gameLayer.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        stopTimer()
        objectsCanRotate = false
        spawnTimerRunning = false
        gravityDirection = "up"
        switchGravity()
        self.enumerateChildNodes(withName: "objectPos") {
            node, stop in
            node.removeAllActions()
            node.run(SKAction.moveTo(x: node.position.x - vars.screenSize.width, duration: vars.gameLayerFadeTime), completion:  {
                node.removeFromParent()
            })
        }
        self.enumerateChildNodes(withName: "objectNeg") {
            node, stop in
            node.removeAllActions()
            node.run(SKAction.moveTo(x: node.position.x + vars.screenSize.width, duration: vars.gameLayerFadeTime), completion: {
                node.removeFromParent()
            })
        }
        if vars.currentGameState == .gameActive {
            gameLayer.tutorialNodeLeft.run(SKAction.fadeOut(withDuration: vars.gameLayerFadeTime))
            gameLayer.tutorialNodeRight.run(SKAction.fadeOut(withDuration: vars.gameLayerFadeTime))
            vars.showTutorial = false
            gameLayer.menuNode.run(SKAction.moveTo(y: vars.screenSize.height + gameLayer.menuNode.frame.size.height + vars.screenSize.height / 40, duration: vars.gameLayerFadeTime))
            gameLayer.scoreNode.run(SKAction.moveTo(y: vars.screenSize.height + gameLayer.scoreNode.frame.height + vars.screenSize.height / 40, duration: vars.gameLayerFadeTime))
            gameLayer.topBar.run(SKAction.moveTo(y: vars.screenSize.height + vars.barHeight / 2, duration: vars.gameLayerFadeTime))
            gameLayer.bottomBar.run(SKAction.moveTo(y: -(vars.barHeight / 2), duration: vars.gameLayerFadeTime))
            gameLayer.player.run(SKAction.fadeOut(withDuration: vars.gameLayerFadeTime), completion: {
                self.gameLayer.removeFromParent()
                self.menuLayer.GCNode.isHidden = false
                self.menuLayer.GCNode.run(SKAction.fadeIn(withDuration: vars.gameLayerFadeTime))
                self.menuLayer.playButton.isHidden = false
                self.menuLayer.playButton.run(SKAction.scale(to: vars.screenSize.height / 1280, duration: vars.gameLayerFadeTime), completion: {
                    self.pulsingPlayButton()
                })
                self.gameStarted = false
                vars.currentGameState = .gameMenu
                if vars.windowIsFullscreen == false {
                    self.viewController.setWindowStyleMenu()
                } else {
                    self.viewController.setWindowStyleFullMenu()
                }
                self.isAnimating = false
            })
        } else if vars.currentGameState == .gameOver {
            highscoreLayer.highscoreNode.run(SKAction.moveTo(x: vars.screenSize.width + highscoreLayer.highscoreNode.frame.size.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.highscoreText.run(SKAction.moveTo(x: vars.screenSize.width + highscoreLayer.highscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.firstHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.secondHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.thirdHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.fourthHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.fifthHighscoreBG.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.firstHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.secondHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.thirdHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.fourthHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            highscoreLayer.fifthHighscoreText.run(SKAction.moveTo(x: -vars.screenSize.width / 2, duration: vars.gameLayerFadeTime))
            gameLayer.menuNode.run(SKAction.moveTo(y: vars.screenSize.height + gameLayer.menuNode.frame.size.height + vars.screenSize.height / 40, duration: vars.gameLayerFadeTime))
            highscoreLayer.shareNode.run(SKAction.moveTo(y: vars.screenSize.height + highscoreLayer.shareNode.frame.height + vars.screenSize.height / 40, duration: vars.gameLayerFadeTime))
            gameLayer.topBar.run(SKAction.moveTo(y: vars.screenSize.height + vars.barHeight / 2, duration: vars.gameLayerFadeTime))
            gameLayer.bottomBar.run(SKAction.moveTo(y: -(vars.barHeight / 2), duration: vars.gameLayerFadeTime), completion: {
                self.gameLayer.removeFromParent()
                self.highscoreLayer.removeFromParent()
                self.menuLayer.playButton.isHidden = false
                self.menuLayer.playButton.run(SKAction.scale(to: vars.screenSize.height / 1280, duration: vars.gameLayerFadeTime), completion: {
                    self.pulsingPlayButton()
                })
                self.menuLayer.highscoreNode.run(SKAction.moveTo(y: vars.screenSize.height - self.menuLayer.highscoreNode.frame.height / 2 - (vars.screenSize.height / 7) / 2, duration: vars.gameLayerFadeTime))
                self.gameStarted = false
                vars.currentGameState = .gameMenu
                self.menuLayer.GCNode.zPosition = 1
                if vars.windowIsFullscreen == false {
                    self.viewController.setWindowStyleMenu()
                } else {
                    self.viewController.setWindowStyleFullMenu()
                }
                self.isAnimating = false
            })
        }
    }
    
    func startTimerAfter() {
        if vars.currentGameState == .gameActive {
            if timerRunning == false {
                timerRunning = true
                let aSelector : Selector = #selector(GameScene.updateTime)
                setupSpawnTimer()
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
                let newTime:TimeInterval = Date.timeIntervalSinceReferenceDate
                startTime = newTime - (stopTime - startTime)
            }
        }
    }
    
    func startTimer() {
        if timerRunning == false {
            timerRunning = true
            let aSelector : Selector = #selector(GameScene.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        timerRunning = false
    }
    
    func stopTimerAfter() {
        stopTime = Date.timeIntervalSinceReferenceDate
        timer.invalidate()
        spawnTimer.invalidate()
        timerRunning = false
        spawnTimerRunning = false
    }
    
    func updateTime() {
        
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        var elapsedTime: TimeInterval = currentTime - startTime
        currentScore = elapsedTime
        if vars.extremeMode == true {
            if currentScore > vars.extHighscore {
                newHighscore = true
                vars.extHighscore = (round(100 * currentScore) / 100)
            }
        } else {
            if currentScore > vars.highscore {
                newHighscore = true
                vars.highscore = (round(100 * currentScore) / 100)
            }
        }
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        if vars.showTutorial == true && seconds >= 5 {
            vars.showTutorial = false
            gameLayer.tutorialNodeLeft.run(SKAction.fadeOut(withDuration: vars.gameLayerFadeTime))
            gameLayer.tutorialNodeRight.run(SKAction.fadeOut(withDuration: vars.gameLayerFadeTime))
        }
        
        if achievements.fiveSeconds == false {
            if seconds >= 5 {
                achievements.fiveSeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_5seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "fiveSeconds")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.fifthteenSeconds == false {
            if seconds >= 15 {
                achievements.fifthteenSeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_15seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "fifthteenSeconds")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.thirtySeconds == false {
            if seconds >= 30 {
                achievements.thirtySeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_30seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "thirtySeconds")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.sixtySeconds == false {
            if minutes >= 1 {
                achievements.sixtySeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_60seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "sixtySeconds")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.onehundredtwentySeconds == false {
            if minutes >= 2 {
                achievements.onehundredtwentySeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_120seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "onehundredtwentySeconds")
                UserDefaults.standard.synchronize()
            }
        }
        
        gameLayer.scoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
        if newHighscore == true {
            menuLayer.highscoreNode.text = "\(strMinutes):\(strSeconds).\(strFraction)"
        }
    }
    
    func showGameLayer() {
        isAnimating = true
        if vars.windowIsFullscreen == false {
            viewController.setWindowStyleGame()
        } else {
            viewController.setWindowStyleFullGame()
        }
        if vars.firstTimePlaying == false {
            vars.showTutorial = true
        }
        gameLayer = GameLayer()
        setColors()
        addChild(gameLayer)
        barsFadedIn = false
        interactionHappend = false
        
        gameLayer.topBar.run(gameLayer.topBarInAction)
        gameLayer.bottomBar.run(gameLayer.bottomBarInAction)
        gameLayer.scoreNode.run(gameLayer.scoreNodeInAction)
        gameLayer.menuNode.run(gameLayer.menuNodeInAction)
        menuLayer.playButton.run(SKAction.scale(to: vars.screenSize.height / 3190, duration: vars.gameLayerFadeTime), completion: {
            if vars.showTutorial == true && vars.extremeMode == false {
                self.gameLayer.tutorialNodeRight.run(SKAction.fadeAlpha(to: vars.tutorialArrowAlpha, duration: vars.gameLayerFadeTime))
                self.gameLayer.tutorialNodeLeft.run(SKAction.fadeAlpha(to: vars.tutorialArrowAlpha, duration: vars.gameLayerFadeTime))
            }
            self.menuLayer.playButton.isHidden = true
            self.setupPhysics()
            vars.currentGameState = .gameActive
            self.setupSpawnTimer()
            self.barsFadedIn = false
            self.objectsCanRotate = true
            self.startTimer()
            self.isAnimating = false
        })
    }
    
    func updateSpawnTimer() {
        getSpawnPositions()
    }
    
    func setupPhysics() {
        gameLayer.topBar.physicsBody = SKPhysicsBody(rectangleOf: gameLayer.topBar.frame.size)
        gameLayer.topBar.physicsBody!.affectedByGravity = false
        gameLayer.topBar.physicsBody!.categoryBitMask = ColliderType.ground.rawValue
        gameLayer.topBar.physicsBody!.contactTestBitMask = ColliderType.player.rawValue
        gameLayer.topBar.physicsBody!.collisionBitMask = ColliderType.player.rawValue
        gameLayer.topBar.physicsBody!.allowsRotation = false
        gameLayer.topBar.physicsBody!.isDynamic = false
        
        gameLayer.bottomBar.physicsBody = SKPhysicsBody(rectangleOf: gameLayer.bottomBar.frame.size)
        gameLayer.bottomBar.physicsBody!.affectedByGravity = false
        gameLayer.bottomBar.physicsBody!.categoryBitMask = ColliderType.ground.rawValue
        gameLayer.bottomBar.physicsBody!.contactTestBitMask = ColliderType.player.rawValue
        gameLayer.bottomBar.physicsBody!.collisionBitMask = ColliderType.player.rawValue
        gameLayer.bottomBar.physicsBody!.allowsRotation = false
        gameLayer.bottomBar.physicsBody!.isDynamic = false
        
        gameLayer.player.physicsBody = SKPhysicsBody(circleOfRadius: gameLayer.player.frame.size.height / 2.5)
        gameLayer.player.physicsBody!.affectedByGravity = true
        gameLayer.player.physicsBody!.categoryBitMask = ColliderType.player.rawValue
        gameLayer.player.physicsBody!.contactTestBitMask = ColliderType.ground.rawValue | ColliderType.objects.rawValue
        gameLayer.player.physicsBody!.collisionBitMask = ColliderType.ground.rawValue | ColliderType.objects.rawValue
        gameLayer.player.physicsBody!.allowsRotation = false
        gameLayer.player.physicsBody?.linearDamping = 1.0
        gameLayer.player.physicsBody?.angularDamping = 1.0
        gameLayer.player.physicsBody?.restitution = 0.0
        gameLayer.player.physicsBody?.friction = 0.0
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
            objectSpawnPoints.remove(at: whichSpawn)
            for i in 0 ..< objectSpawnPoints.count {
                if objectSide == 0 {
                    createObjects(CGPoint(x: vars.screenOutLeft, y: objectSpawnPoints[i]), direction: "right")
                } else if objectSide == 1 {
                    createObjects(CGPoint(x: vars.screenOutRight, y: objectSpawnPoints[i]), direction: "left")
                }
            }
        } else if objectCount == 3 {
            for i in 0 ..< objectCount {
                if objectSide == 0 {
                    createObjects(CGPoint(x: vars.screenOutLeft, y: objectSpawnPoints[i]), direction: "right")
                } else if objectSide == 1 {
                    createObjects(CGPoint(x: vars.screenOutRight, y: objectSpawnPoints[i]), direction: "left")
                }
            }
        }
    }
    
    func createObjects(_ location : CGPoint, direction: String) {
        let object = SKShapeNode(rectOf: CGSize(width: vars.objectSize, height: vars.objectSize), cornerRadius: 3)
        object.position = location
        object.zPosition = 4
        object.fillColor = gameBGColor[currentGameColor]
        object.strokeColor = gameObjectColor[currentGameColor]
        object.lineWidth = vars.screenSize.height / 128
        if location.x == vars.screenOutLeft {
            object.name = "objectNeg"
        } else {
            object.name = "objectPos"
        }
        addChild(object)
        if direction == "right" {
            object.run(moveRightAction, completion: {
                object.removeAllActions()
                object.removeFromParent()
            })
        } else if direction == "left" {
            object.run(moveLeftAction, completion: {
                object.removeAllActions()
                object.removeFromParent()
            })
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            
        case ColliderType.player.rawValue | ColliderType.objects.rawValue:
            contact.bodyA.isDynamic = false
            contact.bodyB.isDynamic = false
            contact.bodyA.node?.removeAllActions()
            contact.bodyA.node?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            contact.bodyB.node?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            contact.bodyB.node?.removeAllActions()
            if contact.bodyA.node?.name == "objectPos" || contact.bodyA.node?.name == "objectNeg" {
                contact.bodyB.node?.position = contact.contactPoint
            } else if contact.bodyB.node?.name == "objectNeg" || contact.bodyB.node?.name == "objectNeg" {
                contact.bodyA.node?.position = contact.contactPoint
            }
            gameOver()
            
        case ColliderType.player.rawValue | ColliderType.ground.rawValue:
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
        if vars.extremeMode == true {
            vars.extHighscore = vars.extHighscore.roundToPlaces(2)
            UserDefaults.standard.set(vars.extHighscore, forKey: "extHighscore")
            UserDefaults.standard.synchronize()
            viewController.reportScoreLeaderboard(identifiers.OSXextremeLeaderboard, score: Int(vars.extHighscore * 100))
            achievementProgress()
            if vars.gameCenterLoggedIn == true {
                viewController.getExtScores()
            } else {
                openNewHighScore()
            }
        } else {
            vars.highscore = vars.highscore.roundToPlaces(2)
            UserDefaults.standard.set(vars.highscore, forKey: "highscore")
            UserDefaults.standard.synchronize()
            viewController.reportScoreLeaderboard(identifiers.OSXnormalLeaderboard, score: Int(vars.highscore * 100))
            achievementProgress()
            if vars.gameCenterLoggedIn == true {
                viewController.getScores()
            } else {
                openNewHighScore()
            }
        }
    }
    
    func achievementProgress() {
        if achievements.fiveSeconds == false {
            if vars.highscore / 0.05 >= 100 {
                achievements.fiveSeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_5seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "fiveSeconds")
                UserDefaults.standard.synchronize()
            } else {
                viewController.reportAchievement((vars.highscore / 0.05), achievementIdentifier: "gravity.achievement_5seconds_osx")
            }
        }
        if achievements.fifthteenSeconds == false {
            if vars.highscore / 0.15 >= 100 {
                achievements.fifthteenSeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_15seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "fifthteenSeconds")
                UserDefaults.standard.synchronize()
            } else {
                viewController.reportAchievement((vars.highscore / 0.15), achievementIdentifier: "gravity.achievement_15seconds_osx")
            }
        }
        if achievements.thirtySeconds == false {
            if vars.highscore / 0.3 >= 100 {
                achievements.thirtySeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_30seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "thirtySeconds")
                UserDefaults.standard.synchronize()
            } else {
                viewController.reportAchievement((vars.highscore / 0.3), achievementIdentifier: "gravity.achievement_30seconds_osx")
            }
        }
        if achievements.sixtySeconds == false {
            if vars.highscore / 0.6 >= 100 {
                achievements.sixtySeconds = true
                viewController.reportAchievement(100, achievementIdentifier: "gravity.achievement_60seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "sixtySeconds")
                UserDefaults.standard.synchronize()
            } else {
                viewController.reportAchievement((vars.highscore / 0.6), achievementIdentifier: "gravity.achievement_60seconds_osx")
            }
        }
        if achievements.onehundredtwentySeconds == false {
            if vars.highscore / 1.2 >= 100 {
                achievements.onehundredtwentySeconds = true
                viewController.reportAchievement(100.00, achievementIdentifier: "gravity.achievement_120seconds_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "onehundredtwentySeconds")
                UserDefaults.standard.synchronize()
            } else {
                viewController.reportAchievement((vars.highscore / 1.2), achievementIdentifier: "gravity.achievement_120seconds_osx")
            }
        }
        
    }
    
    func setHighscoreTextBGSize(_ number: Int) {
        
        highscoreLayer.firstHighscoreBG.position.y = highscoreLayer.firstHighscoreText.position.y
        highscoreLayer.secondHighscoreBG.position.y = highscoreLayer.secondHighscoreText.position.y
        highscoreLayer.thirdHighscoreBG.position.y = highscoreLayer.thirdHighscoreText.position.y
        highscoreLayer.fourthHighscoreBG.position.y = highscoreLayer.fourthHighscoreText.position.y
        highscoreLayer.fifthHighscoreBG.position.y = highscoreLayer.fifthHighscoreText.position.y
        
        if number >= 1 {
            highscoreLayer.firstHighscoreBG.alpha = 1
        }
        if number >= 2 {
            highscoreLayer.secondHighscoreBG.alpha = 1
        }
        if number >= 3 {
            highscoreLayer.thirdHighscoreBG.alpha = 1
        }
        if number >= 4 {
            highscoreLayer.fourthHighscoreBG.alpha = 1
        }
        if number == 5 {
            highscoreLayer.fifthHighscoreBG.alpha = 1
        }
    }
    
    func compareFrameSize() {
        
        var sizes:[CGFloat] = []
        var number:Int = 0
        sizes.append(highscoreLayer.firstHighscoreText.frame.size.height)
        sizes.append(highscoreLayer.secondHighscoreText.frame.size.height)
        sizes.append(highscoreLayer.thirdHighscoreText.frame.size.height)
        sizes.append(highscoreLayer.fourthHighscoreText.frame.size.height)
        sizes.append(highscoreLayer.fifthHighscoreText.frame.size.height)
        
        for size in sizes {
            if size > vars.normalTextFrameHeight {
                let sizeDiff = (size - vars.normalTextFrameHeight) / 4
                if number == 0 {
                    highscoreLayer.firstHighscoreText.position.y = highscoreLayer.firstHighscoreText.position.y - sizeDiff
                    highscoreLayer.firstHighscoreBG.position.y = highscoreLayer.firstHighscoreBG.position.y + sizeDiff
                } else if number == 1 {
                    highscoreLayer.secondHighscoreText.position.y = highscoreLayer.secondHighscoreText.position.y - sizeDiff
                    highscoreLayer.secondHighscoreBG.position.y = highscoreLayer.secondHighscoreBG.position.y + sizeDiff
                } else if number == 2 {
                    highscoreLayer.thirdHighscoreText.position.y = highscoreLayer.thirdHighscoreText.position.y - sizeDiff
                    highscoreLayer.thirdHighscoreBG.position.y = highscoreLayer.thirdHighscoreBG.position.y + sizeDiff
                } else if number == 3 {
                    highscoreLayer.fourthHighscoreText.position.y = highscoreLayer.fourthHighscoreText.position.y - sizeDiff
                    highscoreLayer.fourthHighscoreBG.position.y = highscoreLayer.fourthHighscoreBG.position.y + sizeDiff
                } else if number == 4 {
                    highscoreLayer.fifthHighscoreText.position.y = highscoreLayer.fifthHighscoreText.position.y - sizeDiff
                    highscoreLayer.fifthHighscoreBG.position.y = highscoreLayer.fifthHighscoreBG.position.y + sizeDiff
                } else {
                    print("Frame height comparing error!")
                }
            }
            number += 1
        }
    }
    
    func openNewHighScore() {
        isAnimating = true
        timesPlayedWithoutInteraction = 0
        
        highscoreLayer = HighscoreLayer()
        self.addChild(highscoreLayer)
        
        var namePos:Int = 10
        
        if vars.highscorePlayerNames.count >= 1  && vars.gameCenterLoggedIn == true {
            for i in 0 ..< vars.highscorePlayerNames.count - 1 {
                if vars.highscorePlayerNames[i] == vars.localPlayerName {
                    vars.highscorePlayerScore[i] = self.menuLayer.highscoreNode.text!
                    namePos = i
                }
            }
        }
        if namePos != 10 {
            for j in 0 ..< namePos {
                let i = namePos - j
                let firstStep:String = vars.highscorePlayerScore[i].replacingOccurrences(of: ":", with: "")
                let firstNumber:Int = Int(firstStep.replacingOccurrences(of: ".", with: ""))!
                let secondStep:String = vars.highscorePlayerScore[i - 1].replacingOccurrences(of: ":", with: "")
                let secondNumber:Int = Int(secondStep.replacingOccurrences(of: ".", with: ""))!
                if firstNumber > secondNumber {
                    let cacheScore:String = vars.highscorePlayerScore[i - 1]
                    let cacheName:String = vars.highscorePlayerNames[i - 1]
                    vars.highscorePlayerScore[i - 1] = vars.highscorePlayerScore[i]
                    vars.highscorePlayerNames[i - 1] = vars.highscorePlayerNames[i]
                    vars.highscorePlayerScore[i] = cacheScore
                    vars.highscorePlayerNames[i] = cacheName
                }
            }
        }
        
        
        if vars.gameCenterLoggedIn == true && vars.shouldOpenScoresList == true{
            if vars.highscorePlayerNames.count >= 0 {
                if vars.highscorePlayerNames.count >= 1 {
                    highscoreLayer.firstHighscoreText.text = "\(vars.highscorePlayerScore[0]) - \(vars.highscorePlayerNames[0])"
                    highscoreLayer.firstHighscoreText.alpha = 1
                    highscoreLayer.firstHighscoreText.position.y = vars.screenSize.height / 2
                    setHighscoreTextBGSize(1)
                }
                if vars.highscorePlayerNames.count >= 2 {
                    highscoreLayer.secondHighscoreText.text = "\(vars.highscorePlayerScore[1]) - \(vars.highscorePlayerNames[1])"
                    highscoreLayer.secondHighscoreText.alpha = 1
                    highscoreLayer.firstHighscoreText.position.y = vars.screenSize.height / 2 + highscoreLayer.thirdHighscoreText.frame.size.height
                    highscoreLayer.secondHighscoreText.position.y = vars.screenSize.height / 2 - highscoreLayer.thirdHighscoreText.frame.size.height
                    setHighscoreTextBGSize(2)
                }
                if vars.highscorePlayerNames.count >= 3 {
                    highscoreLayer.thirdHighscoreText.text = "\(vars.highscorePlayerScore[2]) - \(vars.highscorePlayerNames[2])"
                    highscoreLayer.thirdHighscoreText.alpha = 1
                    highscoreLayer.firstHighscoreText.position.y = vars.screenSize.height / 2 + highscoreLayer.thirdHighscoreText.frame.size.height * 2
                    highscoreLayer.secondHighscoreText.position.y = vars.screenSize.height / 2
                    highscoreLayer.thirdHighscoreText.position.y = vars.screenSize.height / 2 - highscoreLayer.thirdHighscoreText.frame.size.height * 2
                    setHighscoreTextBGSize(3)
                }
                if vars.highscorePlayerNames.count >= 4 {
                    highscoreLayer.fourthHighscoreText.text = "\(vars.highscorePlayerScore[3]) - \(vars.highscorePlayerNames[3])"
                    highscoreLayer.fourthHighscoreText.alpha = 1
                    highscoreLayer.firstHighscoreText.position.y = vars.screenSize.height / 2 + highscoreLayer.thirdHighscoreText.frame.size.height * 3
                    highscoreLayer.secondHighscoreText.position.y = vars.screenSize.height / 2 + highscoreLayer.thirdHighscoreText.frame.size.height
                    highscoreLayer.thirdHighscoreText.position.y = vars.screenSize.height / 2 - highscoreLayer.thirdHighscoreText.frame.size.height
                    highscoreLayer.fourthHighscoreText.position.y = vars.screenSize.height / 2 - highscoreLayer.thirdHighscoreText.frame.size.height * 3
                    setHighscoreTextBGSize(4)
                }
                if vars.highscorePlayerNames.count >= 5 {
                    highscoreLayer.fifthHighscoreText.text = "\(vars.highscorePlayerScore[4]) - \(vars.highscorePlayerNames[4])"
                    highscoreLayer.fifthHighscoreText.alpha = 1
                    highscoreLayer.firstHighscoreText.position.y = vars.screenSize.height / 2 + highscoreLayer.thirdHighscoreText.frame.size.height * 4
                    highscoreLayer.secondHighscoreText.position.y = vars.screenSize.height / 2 + highscoreLayer.thirdHighscoreText.frame.size.height * 2
                    highscoreLayer.thirdHighscoreText.position.y = vars.screenSize.height / 2
                    highscoreLayer.fourthHighscoreText.position.y = vars.screenSize.height / 2 - highscoreLayer.thirdHighscoreText.frame.size.height * 2
                    highscoreLayer.fifthHighscoreText.position.y = vars.screenSize.height / 2 - highscoreLayer.thirdHighscoreText.frame.size.height * 4
                    setHighscoreTextBGSize(5)
                }
            }
        }
        
        compareFrameSize()
        gameLayer.tutorialNodeLeft.run(SKAction.fadeOut(withDuration: vars.gameLayerFadeTime))
        gameLayer.tutorialNodeRight.run(SKAction.fadeOut(withDuration: vars.gameLayerFadeTime))
        vars.showTutorial = false
        menuLayer.GCNode.position.y = vars.screenSize.height + menuLayer.GCNode.frame.height + vars.screenSize.height / 40
        gameLayer.scoreNode.run(SKAction.moveTo(y: gameLayer.scoreNode.position.y + vars.screenSize.height / 8, duration: 0.5))
        menuLayer.highscoreNode.run(SKAction.moveTo(y: menuLayer.highscoreNode.position.y + vars.screenSize.height / 8, duration: 0.5), completion: {
            self.menuLayer.GCNode.zPosition = 3
            self.menuLayer.GCNode.run(SKAction.moveTo(y: vars.screenSize.height - (vars.screenSize.height / 7) / 2, duration: 0.5))
            self.highscoreLayer.shareNode.run(SKAction.moveTo(y: vars.screenSize.height - (vars.screenSize.height / 7) / 2, duration: 0.5))
        })
        gameLayer.player.run(SKAction.fadeOut(withDuration: 0.5), completion: {
            if vars.gameCenterLoggedIn == true && vars.shouldOpenScoresList == true {
                self.highscoreLayer.highscoreText.text = self.menuLayer.highscoreNode.text
                self.highscoreLayer.highscoreNode.alpha = 1
                self.highscoreLayer.highscoreText.alpha = 1
                self.highscoreLayer.highscoreNode.run(SKAction.moveTo(x: vars.screenSize.width / 1.33, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.highscoreText.run(SKAction.moveTo(x: vars.screenSize.width / 1.33, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.firstHighscoreBG.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.secondHighscoreBG.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.thirdHighscoreBG.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.fourthHighscoreBG.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.fifthHighscoreBG.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.secondHighscoreText.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.thirdHighscoreText.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.fourthHighscoreText.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.fifthHighscoreText.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime))
                self.highscoreLayer.firstHighscoreText.run(SKAction.moveTo(x: vars.screenSize.width / 6 + self.highscoreLayer.firstHighscoreText.frame.size.width / 2, duration: vars.gameLayerFadeTime), completion: {
                    self.isAnimating = false
                    self.pulsingReplayButton()
                })
            } else {
                self.highscoreLayer.highscoreNode.position.x = vars.screenSize.width / 2
                self.highscoreLayer.highscoreText.position.x = vars.screenSize.width / 2
                self.highscoreLayer.highscoreText.fontColor = self.gameLayer.topBar.fillColor
                self.highscoreLayer.highscoreText.text = self.menuLayer.highscoreNode.text
                self.highscoreLayer.highscoreNode.setScale(0)
                self.highscoreLayer.highscoreNode.alpha = 1
                self.highscoreLayer.highscoreNode.run(SKAction.scale(to: 1, duration: vars.gameLayerFadeTime), completion: {
                    self.highscoreLayer.highscoreText.run(SKAction.fadeIn(withDuration: vars.gameLayerFadeTime / 2), completion: {
                        self.isAnimating = false
                        self.pulsingReplayButton()
                    })
                })
            }
        })
    }
    
    func lerp(_ a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat {
        return (b-a) * fraction + a
    }
    
    func colorTransitionAction(_ fromColor : NSColor, toColor : NSColor, duration : Double = 1.0) -> SKAction {
        var fr:CGFloat = 0
        var fg:CGFloat = 0
        var fb:CGFloat = 0
        var fa:CGFloat = 0
        var tr:CGFloat = 0
        var tg:CGFloat = 0
        var tb:CGFloat = 0
        var ta:CGFloat = 0
        
        fromColor.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        toColor.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
        
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let transColor = NSColor(red: self.lerp(fr, b: tr, fraction: fraction),
                green: self.lerp(fg, b: tg, fraction: fraction),
                blue: self.lerp(fb, b: tb, fraction: fraction),
                alpha: self.lerp(fa, b: ta, fraction: fraction))
            (node as! SKShapeNode).fillColor = transColor
            (node as! SKShapeNode).strokeColor = transColor
            }
        )
    }
    
    func gameOverAfter() {
        isAnimating = true
        UserDefaults.standard.set(vars.gamesPlayed, forKey: "gamesPlayed")
        UserDefaults.standard.synchronize()
        viewController.reportScoreLeaderboard(identifiers.OSXtimesLeaderboard, score: vars.gamesPlayed)
        self.enumerateChildNodes(withName: "objectPos") {
            node, stop in
            node.removeAllActions()
            self.objectMoveLeftAction = SKAction.moveTo(x: node.position.x - vars.screenSize.width, duration: vars.gameLayerFadeTime)
            self.objectMoveLeftAction.timingMode = .linear
            node.run(self.waitAction, completion: {
                self.objectsCanRotate = true
            })
            node.run(SKAction.sequence([
                self.waitAction,
                self.objectMoveLeftAction
                ]), completion: {
                    node.removeFromParent()
            })
        }
        self.enumerateChildNodes(withName: "objectNeg") {
            node, stop in
            node.removeAllActions()
            self.objectMoveRightAction = SKAction.moveTo(x: node.position.x + vars.screenSize.width, duration: vars.gameLayerFadeTime)
            self.objectMoveRightAction.timingMode = .linear
            node.run(self.waitAction, completion: {
                self.objectsCanRotate = true
            })
            node.run(SKAction.sequence([
                self.waitAction,
                self.objectMoveRightAction
                ]), completion: {
                    node.removeFromParent()
            })
        }
        vars.currentGameState = .gameOver

        if newHighscore == true {
            gameLayer.player.run(SKAction.sequence([
                SKAction.scale(to: 0, duration: 0.3),
                SKAction.wait(forDuration: 0.2)
                ]), completion: {
                    self.gotNewHighscore()
            })
            newHighscore = false
        } else {
            newHighscore = false
            gameLayer.player.run(SKAction.sequence([
                self.waitAction,
                SKAction.scale(to: 0, duration: 0.3),
                SKAction.wait(forDuration: 0.2)
                ]), completion: {
                    self.gameLayer.player.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
                    self.gameLayer.player.alpha = 1
                    self.gameLayer.player.run(SKAction.scale(to: 1, duration: 0.3), completion: {
                        self.restartGame()
                        self.isAnimating = false
                    })
            })
        }
    }
    
    func gameOver() {
        spawnTimer.invalidate()
        gameLayer.player.physicsBody?.affectedByGravity = false
        gameLayer.player.physicsBody?.isDynamic = false
        gameLayer.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        stopTimer()
        objectsCanRotate = false
        spawnTimerRunning = false
        vars.gamesPlayed += 1
        if vars.firstTimePlaying == false {
            vars.firstTimePlaying = true
            UserDefaults.standard.set(true, forKey: "firstTimePlaying")
            UserDefaults.standard.synchronize()
        }
        
        let score:Double = currentScore.roundToPlaces(2)
        
        if achievements.pi == false {
            if score == 3.14 {
                achievements.pi = true
                viewController.reportAchievement(100.00, achievementIdentifier: "gravity.achievement_pi_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "pi")
                UserDefaults.standard.synchronize()
            }
        }
        if achievements.newton == false {
            if score == 9.81 {
                achievements.newton = true
                viewController.reportAchievement(100.00, achievementIdentifier: "gravity.achievement_newton_osx", showBannnerIfCompleted: true)
                UserDefaults.standard.set(true, forKey: "newton")
                UserDefaults.standard.synchronize()
            }
        }
        
        if interactionHappend == false {
            timesPlayedWithoutInteraction += 1
            if timesPlayedWithoutInteraction == 2 {
                vars.showTutorial = true
                gameOverAfter()
            } else if timesPlayedWithoutInteraction == 5 {
                goToMenu()
            } else {
                gameOverAfter()
            }
        } else {
            timesPlayedWithoutInteraction = 0
            gameOverAfter()
        }
    }
    
    func restartGame() {
        vars.currentGameState = .gameActive
        objectsCanRotate = true
        objectRotationPos = 0
        objectRotationNeg = 360
        interactionHappend = false
        gameLayer.scoreNode.text = "00:00:00"
        startTimer()
        setupSpawnTimer()
        gameLayer.player.physicsBody?.affectedByGravity = true
        gameLayer.player.physicsBody?.isDynamic = true
        gravityDirection = "up"
        if vars.showTutorial == true && vars.extremeMode == false {
            gameLayer.tutorialNodeRight.run(SKAction.fadeAlpha(to: vars.tutorialArrowAlpha, duration: vars.gameLayerFadeTime))
            gameLayer.tutorialNodeLeft.run(SKAction.fadeAlpha(to: vars.tutorialArrowAlpha, duration: vars.gameLayerFadeTime))
        }
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
    
    override func update(_ currentTime: TimeInterval) {
        
        let nowCursor = NSCursor.current()
        if vars.cursorTime >= 150 {
            NSCursor.setHiddenUntilMouseMoves(true)
            vars.cursorTime = 0
        } else {
            if nowCursor.hotSpot != preCursorPos {
                vars.cursorTime = 0
                preCursorPos = nowCursor.hotSpot
            } else {
                vars.cursorTime += 1
            }
        }
        
        self.enumerateChildNodes(withName: "objectPos") {
            node, stop in
            (node as! SKShapeNode).fillColor = self.menuLayer.backgroundNode.fillColor
            (node as! SKShapeNode).strokeColor = self.gameLayer.topBar.strokeColor
            if node.position.x < vars.screenSize.width && node.physicsBody == nil {
                node.physicsBody = SKPhysicsBody(circleOfRadius: vars.objectSize / 2)
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.categoryBitMask = ColliderType.objects.rawValue
                node.physicsBody?.contactTestBitMask = ColliderType.player.rawValue
                node.physicsBody?.collisionBitMask = 0
                node.physicsBody?.usesPreciseCollisionDetection = true
                node.physicsBody?.restitution = 0.0
                node.physicsBody?.isDynamic = false
                node.physicsBody?.allowsRotation = false
            }
            if self.objectsCanRotate == true {
                (node as! SKShapeNode).zRotation = self.objectRotationPos.degreesToRadians
            }
        }
        self.enumerateChildNodes(withName: "objectNeg") {
            node, stop in
            (node as! SKShapeNode).fillColor = self.menuLayer.backgroundNode.fillColor
            (node as! SKShapeNode).strokeColor = self.gameLayer.topBar.strokeColor
            if node.position.x > 0 && node.physicsBody == nil {
                node.physicsBody = SKPhysicsBody(circleOfRadius: vars.objectSize / 2)
                node.physicsBody?.affectedByGravity = false
                node.physicsBody?.categoryBitMask = ColliderType.objects.rawValue
                node.physicsBody?.contactTestBitMask = ColliderType.player.rawValue
                node.physicsBody?.collisionBitMask = 0
                node.physicsBody?.usesPreciseCollisionDetection = true
                node.physicsBody?.restitution = 0.0
                node.physicsBody?.isDynamic = false
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
            highscoreLayer.firstHighscoreText.fontColor = gameLayer.topBar.strokeColor
            highscoreLayer.secondHighscoreText.fontColor = gameLayer.topBar.strokeColor
            highscoreLayer.thirdHighscoreText.fontColor = gameLayer.topBar.strokeColor
            highscoreLayer.fourthHighscoreText.fontColor = gameLayer.topBar.strokeColor
            highscoreLayer.fifthHighscoreText.fontColor = gameLayer.topBar.strokeColor
        }
        if vars.currentGameState == .gameActive {
            if moveRight == true && moveLeft == false {
                gameLayer.player.position.x += vars.playerSideSpeed
                if gameLayer.player.position.x >= vars.screenSize.width {
                    gameLayer.player.position.x = 0
                }
            } else if moveLeft == true && moveRight == false {
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
extension NSColor {
    var coreImageColor: CoreImage.CIColor? {
        return CoreImage.CIColor(color: self)
    }
}
extension Double {
    mutating func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
extension Int {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}
