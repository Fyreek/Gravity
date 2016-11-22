//
//  MenuLayer.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 13/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//

import SpriteKit

class MenuLayer: SKNode {
    
    //Nodes
    var backgroundNode:SKShapeNode = SKShapeNode()
    var playButton = SKSpriteNode()
    var highscoreNode = SKLabelNode()
    var GCNode = SKSpriteNode()
    var circleNode = SKShapeNode()
    var circleNode2 = SKShapeNode()
    var splashNode = SKShapeNode()
    var notificationNode = SKShapeNode()
    
    override init() {
        super.init()
        
        backgroundNode = SKShapeNode(rectOf: vars.screenSize)
        backgroundNode.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        backgroundNode.zPosition = 0
        addChild(backgroundNode)
        
        playButton = SKSpriteNode(imageNamed: "PlayButton")
        playButton.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        playButton.setScale(vars.screenSize.height / 1280)
        playButton.zPosition = 2
        playButton.name = "playButton"
        addChild(playButton)
        
        highscoreNode = SKLabelNode(fontNamed: "SF-UI-Display-Regular")
        highscoreNode.text = "00:00.00"
        highscoreNode.fontSize = vars.screenSize.height / 13
        highscoreNode.fontColor = SKColor.white
        highscoreNode.horizontalAlignmentMode = .left
        highscoreNode.zPosition = 2
        highscoreNode.position = CGPoint(x: vars.screenSize.width - highscoreNode.frame.width - vars.screenSize.width / 60, y: vars.screenSize.height - highscoreNode.frame.height / 2 - (vars.screenSize.height / 7) / 2)
        addChild(highscoreNode)
        
        GCNode = SKSpriteNode(imageNamed: "GameCenter")
        GCNode.setScale(vars.screenSize.height / 1280)
        GCNode.position = CGPoint(x: GCNode.frame.size.width / 2 + vars.screenSize.width / 66, y: vars.screenSize.height - ((vars.screenSize.height / 7) / 2))
        GCNode.zPosition = 1
        GCNode.name = "GCNode"
        addChild(GCNode)
        
//        #if os(tvOS)
//            notificationNode = SKShapeNode(rectOf: CGSize(width: vars.screenSize.width / 3, height: (vars.barHeight * 2) / 3), cornerRadius: 1)
//            notificationNode.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height - vars.barHeight / 2)
//            
//            notificationNode.zPosition = 10
//            addChild(notificationNode)
//        #endif
        
        #if os(iOS)
            
            GCNode.alpha = 0
            GCNode.isHidden = true
            highscoreNode.alpha = 0
            highscoreNode.isHidden = true
            
            splashNode = SKShapeNode(circleOfRadius: vars.screenSize.height / 200 * 60)
            splashNode.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
            splashNode.zPosition = 2.5
            splashNode.fillColor = SKColor.white
            splashNode.strokeColor = SKColor.white
            addChild(splashNode)
            
        #endif
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
}
