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
    
    var firstHighscoreBG:SKShapeNode = SKShapeNode()
    var secondHighscoreBG:SKShapeNode = SKShapeNode()
    var thirdHighscoreBG:SKShapeNode = SKShapeNode()
    var fourthHighscoreBG:SKShapeNode = SKShapeNode()
    var fifthHighscoreBG:SKShapeNode = SKShapeNode()
    
    var firstHighscoreText:SKLabelNode = SKLabelNode()
    var secondHighscoreText:SKLabelNode = SKLabelNode()
    var thirdHighscoreText:SKLabelNode = SKLabelNode()
    var fourthHighscoreText:SKLabelNode = SKLabelNode()
    var fifthHighscoreText:SKLabelNode = SKLabelNode()
    
    //Vars
    var highscoreBGHeight:CGFloat = 0
    var cnRnd:CGFloat = 0
    
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
        addChild(highscoreNode)
    
        highscoreText = SKLabelNode(fontNamed: "Helvetia")
        highscoreText.text = "00:00.00"
        highscoreText.fontSize = vars.screenSize.height / 13
        highscoreText.alpha = 0
        highscoreText.fontColor = SKColor.whiteColor()
        highscoreText.zPosition = 4
        highscoreText.position = CGPoint(x: vars.screenSize.width * 1.5, y: vars.screenSize.height / 2 - highscoreText.frame.size.height / 2)
        addChild(highscoreText)
        
        firstHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        firstHighscoreText.text = "00:00.00 - Name"
        firstHighscoreText.fontSize = vars.screenSize.height / 26
        firstHighscoreText.horizontalAlignmentMode = .Center
        firstHighscoreText.verticalAlignmentMode = .Center
        firstHighscoreText.alpha = 0
        firstHighscoreText.fontColor = SKColor.whiteColor()
        firstHighscoreText.zPosition = 4
        firstHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        addChild(firstHighscoreText)
        
        secondHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        secondHighscoreText.text = "00:00.00 - Name"
        secondHighscoreText.fontSize = vars.screenSize.height / 26
        secondHighscoreText.horizontalAlignmentMode = .Center
        secondHighscoreText.verticalAlignmentMode = .Center
        secondHighscoreText.alpha = 0
        secondHighscoreText.fontColor = SKColor.whiteColor()
        secondHighscoreText.zPosition = 4
        secondHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        addChild(secondHighscoreText)
        
        thirdHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        thirdHighscoreText.text = "00:00.00 - Name"
        thirdHighscoreText.fontSize = vars.screenSize.height / 26
        thirdHighscoreText.horizontalAlignmentMode = .Center
        thirdHighscoreText.verticalAlignmentMode = .Center
        thirdHighscoreText.alpha = 0
        thirdHighscoreText.fontColor = SKColor.whiteColor()
        thirdHighscoreText.zPosition = 4
        thirdHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        addChild(thirdHighscoreText)
        
        fourthHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        fourthHighscoreText.text = "00:00.00 - Name"
        fourthHighscoreText.fontSize = vars.screenSize.height / 26
        fourthHighscoreText.horizontalAlignmentMode = .Center
        fourthHighscoreText.verticalAlignmentMode = .Center
        fourthHighscoreText.alpha = 0
        fourthHighscoreText.fontColor = SKColor.whiteColor()
        fourthHighscoreText.zPosition = 4
        fourthHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        addChild(fourthHighscoreText)
        
        fifthHighscoreText = SKLabelNode(fontNamed: "Helvetia")
        fifthHighscoreText.text = "00:00.00 - Name"
        fifthHighscoreText.fontSize = vars.screenSize.height / 26
        fifthHighscoreText.horizontalAlignmentMode = .Center
        fifthHighscoreText.verticalAlignmentMode = .Center
        fifthHighscoreText.alpha = 0
        fifthHighscoreText.fontColor = SKColor.whiteColor()
        fifthHighscoreText.zPosition = 4
        fifthHighscoreText.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        addChild(fifthHighscoreText)
        
        vars.normalTextFrameHeight = firstHighscoreText.frame.size.height
        highscoreBGHeight = firstHighscoreText.frame.size.height + vars.screenSize.height / 60
        cnRnd = vars.screenSize.width / 160
        
        firstHighscoreBG = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.width / 3, height: highscoreBGHeight), cornerRadius: cnRnd)
        firstHighscoreBG.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        firstHighscoreBG.fillColor = SKColor.whiteColor()
        firstHighscoreBG.zPosition = 3
        firstHighscoreBG.lineWidth = 0
        firstHighscoreBG.alpha = 0
        addChild(firstHighscoreBG)
        
        secondHighscoreBG = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.width / 3, height: highscoreBGHeight), cornerRadius: cnRnd)
        secondHighscoreBG.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        secondHighscoreBG.fillColor = SKColor.whiteColor()
        secondHighscoreBG.zPosition = 3
        secondHighscoreBG.lineWidth = 0
        secondHighscoreBG.alpha = 0
        addChild(secondHighscoreBG)
        
        thirdHighscoreBG = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.width / 3, height: highscoreBGHeight), cornerRadius: cnRnd)
        thirdHighscoreBG.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        thirdHighscoreBG.fillColor = SKColor.whiteColor()
        thirdHighscoreBG.zPosition = 3
        thirdHighscoreBG.lineWidth = 0
        thirdHighscoreBG.alpha = 0
        addChild(thirdHighscoreBG)
        
        fourthHighscoreBG = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.width / 3, height: highscoreBGHeight), cornerRadius: cnRnd)
        fourthHighscoreBG.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        fourthHighscoreBG.fillColor = SKColor.whiteColor()
        fourthHighscoreBG.zPosition = 3
        fourthHighscoreBG.lineWidth = 0
        fourthHighscoreBG.alpha = 0
        addChild(fourthHighscoreBG)
        
        fifthHighscoreBG = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.width / 3, height: highscoreBGHeight), cornerRadius: cnRnd)
        fifthHighscoreBG.position = CGPoint(x: -vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        fifthHighscoreBG.fillColor = SKColor.whiteColor()
        fifthHighscoreBG.zPosition = 3
        fifthHighscoreBG.lineWidth = 0
        fifthHighscoreBG.alpha = 0
        addChild(fifthHighscoreBG)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
}