//
//  HighScoreLayer.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 18/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//


import SpriteKit

class HighscoreLayer: SKNode {
    
    //Nodes
    var shareNode:SKSpriteNode = SKSpriteNode()
    var highscoreNode:SKShapeNode = SKShapeNode()
    var highscoreText:SKLabelNode = SKLabelNode()
    
    //Vars
    
    override init() {
        super.init()
    
        shareNode = SKSpriteNode(imageNamed: "Share")
        shareNode.position = CGPoint(x: vars.screenSize.width - (shareNode.frame.size.width / 2 + vars.screenSize.width / 66), y: (vars.screenSize.height - (vars.screenSize.height / 2 - shareNode.frame.size.height / 2) / 6 ))
        shareNode.zPosition = 3
        shareNode.alpha = 0
        shareNode.name = "shareNode"
        addChild(shareNode)
        
        highscoreNode = SKShapeNode(circleOfRadius: vars.screenSize.height / 5)
        highscoreNode.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        highscoreNode.fillColor = SKColor.whiteColor()
        highscoreNode.zPosition = 3
        highscoreNode.alpha = 0
        highscoreNode.name = "highscoreNodeEnd"
        addChild(highscoreNode)
    
        highscoreText = SKLabelNode(fontNamed: "Helvetia")
        highscoreText.text = "00:00.00"
        highscoreText.fontSize = vars.screenSize.height / 13
        highscoreText.alpha = 0
        highscoreText.fontColor = SKColor.whiteColor()
        highscoreText.zPosition = 4
        highscoreText.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2 - highscoreText.frame.size.height / 2)
        highscoreText.name = "highscoreTextEnd"
        addChild(highscoreText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
}