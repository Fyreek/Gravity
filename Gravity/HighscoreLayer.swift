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
    
    var highscoreTextBG:SKShapeNode = SKShapeNode()
    var firstHighscoreText:SKLabelNode = SKLabelNode()
    var secondHighscoreText:SKLabelNode = SKLabelNode()
    var thirdHighscoreText:SKLabelNode = SKLabelNode()
    var fourthHighscoreText:SKLabelNode = SKLabelNode()
    var fifthHighscoreText:SKLabelNode = SKLabelNode()
    
    //Vars
    
    override init() {
        super.init()
    
        shareNode = SKSpriteNode(imageNamed: "Share")
        shareNode.setScale(vars.screenSize.height / 1280)
        shareNode.position = CGPoint(x: vars.screenSize.width - (shareNode.frame.size.width / 2) - vars.screenSize.width / 66, y: vars.screenSize.height + shareNode.frame.height + vars.screenSize.height / 40)
        shareNode.zPosition = 3
        shareNode.name = "shareNode"
        addChild(shareNode)
        
        highscoreNode = SKShapeNode(circleOfRadius: vars.screenSize.height / 5)
        highscoreNode.position = CGPoint(x: vars.screenSize.width * 1.5, y: vars.screenSize.height / 2)
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
        highscoreText.position = CGPoint(x: vars.screenSize.width * 1.5, y: vars.screenSize.height / 2 - highscoreText.frame.size.height / 2)
        highscoreText.name = "highscoreTextEnd"
        addChild(highscoreText)
        
        firstHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        firstHighscoreText.text = "00:00.00 - Name"
        firstHighscoreText.fontSize = vars.screenSize.height / 26
        firstHighscoreText.horizontalAlignmentMode = .Left
        firstHighscoreText.alpha = 0
        firstHighscoreText.fontColor = SKColor.whiteColor()
        firstHighscoreText.zPosition = 4
        firstHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        firstHighscoreText.name = "firstHighscoreText"
        addChild(firstHighscoreText)
        
        secondHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        secondHighscoreText.text = "00:00.00 - Name"
        secondHighscoreText.fontSize = vars.screenSize.height / 26
        secondHighscoreText.horizontalAlignmentMode = .Left
        secondHighscoreText.alpha = 0
        secondHighscoreText.fontColor = SKColor.whiteColor()
        secondHighscoreText.zPosition = 4
        secondHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        secondHighscoreText.name = "secondHighscoreText"
        addChild(secondHighscoreText)
        
        thirdHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        thirdHighscoreText.text = "00:00.00 - Name"
        thirdHighscoreText.fontSize = vars.screenSize.height / 26
        thirdHighscoreText.horizontalAlignmentMode = .Left
        thirdHighscoreText.alpha = 0
        thirdHighscoreText.fontColor = SKColor.whiteColor()
        thirdHighscoreText.zPosition = 4
        thirdHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        thirdHighscoreText.name = "thirdHighscoreText"
        addChild(thirdHighscoreText)
        
        fourthHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        fourthHighscoreText.text = "00:00.00 - Name"
        fourthHighscoreText.fontSize = vars.screenSize.height / 26
        fourthHighscoreText.horizontalAlignmentMode = .Left
        fourthHighscoreText.alpha = 0
        fourthHighscoreText.fontColor = SKColor.whiteColor()
        fourthHighscoreText.zPosition = 4
        fourthHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        fourthHighscoreText.name = "fourthHighscoreText"
        addChild(fourthHighscoreText)
        
        fifthHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        fifthHighscoreText.text = "00:00.00 - Name"
        fifthHighscoreText.fontSize = vars.screenSize.height / 26
        fifthHighscoreText.horizontalAlignmentMode = .Left
        fifthHighscoreText.alpha = 0
        fifthHighscoreText.fontColor = SKColor.whiteColor()
        fifthHighscoreText.zPosition = 4
        fifthHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        fifthHighscoreText.name = "fifthHighscoreText"
        addChild(fifthHighscoreText)
        
        highscoreTextBG = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.width / 3, height: firstHighscoreText.frame.size.height * 10), cornerRadius: vars.screenSize.height / 20)
        highscoreTextBG.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        highscoreTextBG.fillColor = SKColor.whiteColor()
        highscoreTextBG.strokeColor = colors.blueObjectColor
        highscoreTextBG.zPosition = 3
        highscoreTextBG.lineWidth = 6
        highscoreTextBG.alpha = 0
        highscoreTextBG.name = "highscoreTextBG"
        addChild(highscoreTextBG)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
}