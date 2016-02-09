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
    
    override init() {
        super.init()
        
        backgroundNode = SKShapeNode(rectOfSize: vars.screenSize)
        backgroundNode.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        backgroundNode.zPosition = 0
        addChild(backgroundNode)
        
        playButton = SKSpriteNode(imageNamed: "PlayButton")
        playButton.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        playButton.setScale(vars.screenSize.height / 1280)
        playButton.zPosition = 2
        playButton.name = "playButton"
        addChild(playButton)
        
        circleNode = SKShapeNode(circleOfRadius: vars.screenSize.height / 6.5)
        circleNode.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        circleNode.zPosition = 1
        circleNode.strokeColor = SKColor.whiteColor()
        circleNode.lineWidth = vars.screenSize.height / 64
        addChild(circleNode)
        
        circleNode2 = SKShapeNode(circleOfRadius: vars.screenSize.height / 5)
        circleNode2.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        circleNode2.zPosition = 1
        circleNode2.strokeColor = SKColor.whiteColor()
        circleNode2.lineWidth = vars.screenSize.height / 128
        addChild(circleNode2)
        
        highscoreNode = SKLabelNode(fontNamed: "Helvetica")
        highscoreNode.text = "00:00.00"
        highscoreNode.fontSize = vars.screenSize.height / 13
        highscoreNode.fontColor = SKColor.whiteColor()
        highscoreNode.horizontalAlignmentMode = .Left
        highscoreNode.zPosition = 2
        highscoreNode.position = CGPoint(x: vars.screenSize.width - highscoreNode.frame.width - vars.screenSize.width / 60, y: vars.screenSize.height - highscoreNode.frame.height / 2 - (vars.screenSize.height / 7) / 2)
        highscoreNode.name = "highscoreNode"
        addChild(highscoreNode)
        
        GCNode = SKSpriteNode(imageNamed: "GameCenter")
        GCNode.setScale(vars.screenSize.height / 1280)
        GCNode.position = CGPoint(x: GCNode.frame.size.width / 2 + vars.screenSize.width / 66, y: vars.screenSize.height - ((vars.screenSize.height / 7) / 2))
        GCNode.zPosition = 1
        GCNode.name = "GCNode"
        addChild(GCNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
    
}
