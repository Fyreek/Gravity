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
    let fadeColorAction = SKAction.customActionWithDuration(0.2, actionBlock: {(node: SKNode!, elapsedTime: CGFloat) -> Void in
        (node as! SKShapeNode).fillColor = SKColor.lightGrayColor()
        (node as! SKShapeNode).strokeColor = SKColor.lightGrayColor()
    })
    let fadeOutColorAction = SKAction.customActionWithDuration(0.2, actionBlock: {(node: SKNode!, elapsedTime: CGFloat) -> Void in
        (node as! SKShapeNode).fillColor = SKColor.whiteColor()
        (node as! SKShapeNode).strokeColor = SKColor.whiteColor()
    })

    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        loadValues()
        interfaceSetup()
        
    }
    
    func loadValues() {
        interScene.screenSize = (view?.frame.size)!
        interScene.barHeight = interScene.screenSize.height / 7
        print(interScene.screenSize)
    }
    
    func interfaceSetup() {
        menuLayer = MenuLayer()
        self.addChild(menuLayer)
    }
    
    override func screenInteractionStarted(location: CGPoint) {
        if self.nodeAtPoint(location) == menuLayer.playButton || self.nodeAtPoint(location) == menuLayer.playArrow {
            lastNodeName = menuLayer.playButton.name!
            menuLayer.playButton.runAction(fadeColorAction)
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
    }
    
    override func screenInteractionEnded(location: CGPoint) {
        if self.nodeAtPoint(location) == menuLayer.playButton || self.nodeAtPoint(location) == menuLayer.playArrow {
            if lastNodeName == menuLayer.playButton.name {
                lastNodeName = ""
                menuLayer.playButton.runAction(fadeOutColorAction)
                showGameLayer()
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
        
        menuLayer.playArrow.runAction(SKAction.fadeOutWithDuration(interScene.gameLayerFadeTime))
        menuLayer.GCNode.runAction(SKAction.fadeOutWithDuration(interScene.gameLayerFadeTime))
        gameLayer.topBar.runAction(gameLayer.topBarInAction)
        gameLayer.bottomBar.runAction(gameLayer.bottomBarInAction)
        menuLayer.playButton.runAction(SKAction.scaleTo(0.5, duration: interScene.gameLayerFadeTime))
        menuLayer.playButton.runAction(SKAction.scaleTo(0.5, duration: interScene.gameLayerFadeTime), completion: {
            self.menuLayer.playButton.hidden = true
            self.setupPhysics()
            self.currentGameState = .gameActive
        })
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
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 9.8)
        } else if gravityDirection == "up" {
            gravityDirection = "down"
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            
        case ColliderType.Player.rawValue | ColliderType.Ground.rawValue:
            print("Player Ground Collision")
            switchGravity()
            
        case ColliderType.Player.rawValue | ColliderType.Objects.rawValue:
            print("Player Object Collision")
            
        default:
            print("unkown collision")
        }
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
