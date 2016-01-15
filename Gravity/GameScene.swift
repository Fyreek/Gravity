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
    
    //Vars
    var lastNodeName = ""
    var gravityDirection = "down"
    var currentGameState:gameState = .gameMenu
    var moveLeft:Bool = false
    var moveRight:Bool = false
    var spawnTimer = NSTimer()
    
    //Actions
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
        interScene.screenSize = (view?.frame.size)!
        interScene.barHeight = interScene.screenSize.height / 7
        interScene.objectSize = interScene.screenSize.height / 40
        interScene.screenOutLeft = -interScene.objectSize * 2
        interScene.screenOutRight = interScene.screenSize.width + interScene.objectSize * 2
        
        waitAction = SKAction.waitForDuration(interScene.objectWait)
        moveLeftAction = SKAction.sequence([
            waitAction,
            SKAction.moveToX(interScene.screenOutLeft, duration: interScene.objectMoveTime)
        ])
        moveRightAction = SKAction.sequence([
                waitAction,
            SKAction.moveToX(interScene.screenOutRight, duration: interScene.objectMoveTime)
        ])
    }
    
    func interfaceSetup() {
        menuLayer = MenuLayer()
        self.addChild(menuLayer)
    }
    
    func setupSpawnTimer() {
        self.spawnTimer = NSTimer.scheduledTimerWithTimeInterval(interScene.timerWait, target: self, selector: Selector("updateSpawnTimer"), userInfo: nil, repeats: true)
    }
    
    override func screenInteractionStarted(location: CGPoint) {
        if self.nodeAtPoint(location) == menuLayer.playButton {
            lastNodeName = menuLayer.playButton.name!
            menuLayer.playButton.runAction(fadeColorAction)
        } else if self.nodeAtPoint(location) == menuLayer.GCNode {
            lastNodeName = menuLayer.GCNode.name!
            menuLayer.GCNode.runAction(fadeColorAction)
        } else {
            if location.x >= interScene.screenSize.width / 2 {
                moveLeft = false
                moveRight = true
            } else if location.x <= interScene.screenSize.width / 2 {
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
                if location.x >= interScene.screenSize.width / 2 {
                    moveLeft = false
                    moveRight = true
                } else if location.x <= interScene.screenSize.width / 2 {
                    moveRight = false
                    moveLeft = true
                }
            }
        }
    }
    
    override func screenInteractionEnded(location: CGPoint) {
        if self.nodeAtPoint(location) == menuLayer.playButton || self.nodeAtPoint(location) == menuLayer.GCNode {
            if lastNodeName == menuLayer.playButton.name {
                lastNodeName = ""
                menuLayer.playButton.runAction(fadeOutColorAction)
                showGameLayer()
            } else if lastNodeName == menuLayer.GCNode.name {
                lastNodeName = ""
                menuLayer.GCNode.runAction(fadeOutColorAction)
                EGC.showGameCenterLeaderboard(leaderboardIdentifier: "IdentifierLeaderboard")
            } else {
                removeNodeAction()
            }
        } else {
            removeNodeAction()
        }
    }
    
    func showGameLayer() {
        gameLayer = GameLayer()
        addChild(gameLayer)
        
        menuLayer.GCNode.runAction(SKAction.fadeOutWithDuration(interScene.gameLayerFadeTime))
        gameLayer.topBar.runAction(gameLayer.topBarInAction)
        gameLayer.bottomBar.runAction(gameLayer.bottomBarInAction)
        gameLayer.scoreNode.runAction(gameLayer.scoreNodeInAction)
        menuLayer.playButton.runAction(SKAction.scaleTo(0.5, duration: interScene.gameLayerFadeTime), completion: {
            self.menuLayer.playButton.hidden = true
            self.setupPhysics()
            self.currentGameState = .gameActive
            self.setupSpawnTimer()
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
        
        gameLayer.player.physicsBody = SKPhysicsBody(circleOfRadius: gameLayer.player.frame.size.height / 2)
        gameLayer.player.physicsBody!.affectedByGravity = true
        gameLayer.player.physicsBody!.categoryBitMask = ColliderType.Player.rawValue
        gameLayer.player.physicsBody!.contactTestBitMask = ColliderType.Ground.rawValue | ColliderType.Objects.rawValue
        gameLayer.player.physicsBody!.collisionBitMask = ColliderType.Ground.rawValue | ColliderType.Objects.rawValue
        gameLayer.player.physicsBody!.allowsRotation = false
    }
    
    func switchGravity() {
        if gravityDirection == "down" {
            gravityDirection = "up"
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: interScene.gravity)
        } else if gravityDirection == "up" {
            gravityDirection = "down"
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -interScene.gravity)
        }
    }
    
    func getSpawnPositions() {
        var objectCount:Int = Int(arc4random_uniform(3))
        objectCount += 1
        let objectSide:Int = Int(arc4random_uniform(2))
        var objectSpawnPoints:[CGFloat] = []
        let gameSizeY:CGFloat = interScene.screenSize.height - interScene.barHeight * 2
        let spawnSpace:CGFloat = gameSizeY / 4
        
        objectSpawnPoints.append(interScene.barHeight + spawnSpace)
        objectSpawnPoints.append(interScene.barHeight + spawnSpace * 2)
        objectSpawnPoints.append(interScene.barHeight + spawnSpace * 3)
        
        //Spawning
        
        if objectCount == 1 {
            let whichSpawn:Int =  Int(arc4random_uniform(3))
            if objectSide == 0 {
                createObjects(CGPoint(x: interScene.screenOutLeft, y: objectSpawnPoints[whichSpawn]), direction: "right")
            } else if objectSide == 1 {
                createObjects(CGPoint(x: interScene.screenOutRight, y: objectSpawnPoints[whichSpawn]), direction: "left")
            }
        } else if objectCount == 2 {
            let whichSpawn:Int = Int(arc4random_uniform(3))
            objectSpawnPoints.removeAtIndex(whichSpawn)
            for var i = 0; i < objectSpawnPoints.count; i++ {
                if objectSide == 0 {
                    createObjects(CGPoint(x: interScene.screenOutLeft, y: objectSpawnPoints[i]), direction: "right")
                } else if objectSide == 1 {
                    createObjects(CGPoint(x: interScene.screenOutRight, y: objectSpawnPoints[i]), direction: "left")
                }
            }
        } else if objectCount == 3 {
            for var i = 0; i < objectCount; i++ {
                if objectSide == 0 {
                    createObjects(CGPoint(x: interScene.screenOutLeft, y: objectSpawnPoints[i]), direction: "right")
                } else if objectSide == 1 {
                    createObjects(CGPoint(x: interScene.screenOutRight, y: objectSpawnPoints[i]), direction: "left")
                }
            }
        }
    }
    
    func createObjects(location : CGPoint, direction: String) {
        let object = SKShapeNode(rectOfSize: CGSize(width: interScene.objectSize, height: interScene.objectSize))
        object.position = location
        object.zPosition = 3
        object.fillColor = colors.blueObjectColor
        object.strokeColor = colors.blueObjectBorderColor
        object.lineWidth = interScene.objectBorderWidth
        object.name = "object"
        object.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: interScene.objectSize, height: interScene.objectSize))
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
            print("Player Object Collision")
            gameOver()
        default:
            print("unkown collision")
        }
    }
    
    func gameOver() {
        spawnTimer.invalidate()
        self.enumerateChildNodesWithName("object") {
            node, stop in
            node.removeAllActions()
            node.runAction(SKAction.sequence([
                self.waitAction,
                SKAction.fadeOutWithDuration(interScene.objectFadeOutDuration)
            ]), completion: {
                node.removeFromParent()
            })
        }
        currentGameState = .gameOver
        gameLayer.player.physicsBody?.affectedByGravity = false
        gameLayer.player.physicsBody?.dynamic = false
        
        gameLayer.player.runAction(SKAction.sequence([
            self.waitAction,
            SKAction.moveTo(CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height / 2), duration: interScene.objectFadeOutDuration)
        ]))
        gameLayer.player.runAction(SKAction.sequence([
            self.waitAction,
            SKAction.moveTo(CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height / 2), duration: interScene.objectFadeOutDuration)
        ]), completion: {
            self.restartGame()
        })
    }
    
    func restartGame() {
        currentGameState = .gameActive
        setupSpawnTimer()
        gameLayer.player.physicsBody?.affectedByGravity = true
        gameLayer.player.physicsBody?.dynamic = true
        gravityDirection = "up"
        switchGravity()
    }
    
    override func update(currentTime: CFTimeInterval) {
        if currentGameState == .gameActive {
            if moveRight == true {
                gameLayer.player.position.x += interScene.playerSideSpeed
                if gameLayer.player.position.x >= interScene.screenSize.width {
                    gameLayer.player.position.x = 0
                }
            } else if moveLeft == true {
                gameLayer.player.position.x -= interScene.playerSideSpeed
                if gameLayer.player.position.x <= 0 {
                    gameLayer.player.position.x = interScene.screenSize.width
                }
            }
        }
    }
}
