//
//  HighScoreLayer.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 18/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//


import SpriteKit

class HighScoreLayer: SKNode {
    
    //Nodes
    var shareNode:SKShapeNode = SKShapeNode()
    var highScoreNode:SKShapeNode = SKShapeNode()
    var highScoreText:SKLabelNode = SKLabelNode()
    
    //Vars
    
    override init() {
        super.init()
    
        shareNode = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.height / 20, height: vars.screenSize.height / 20))
        shareNode.position = CGPoint(x: vars.screenSize.width - (shareNode.frame.size.width / 2 + vars.screenSize.width / 66), y: (vars.screenSize.height - (vars.screenSize.height / 2 - shareNode.frame.size.height / 2) / 6 ))
        shareNode.fillColor = SKColor.whiteColor()
        shareNode.zPosition = 3
        shareNode.alpha = 0
        shareNode.name = "shareNode"
        addChild(shareNode)
        
        highScoreNode = SKShapeNode(circleOfRadius: vars.screenSize.height / 5)
        highScoreNode.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        highScoreNode.fillColor = SKColor.whiteColor()
        highScoreNode.zPosition = 3
        highScoreNode.alpha = 0
        highScoreNode.name = "highScoreNodeEnd"
        addChild(highScoreNode)
    
        highScoreText = SKLabelNode(fontNamed: "Helvetia")
        highScoreText.text = "00:00.00"
        highScoreText.fontSize = 28
        highScoreText.alpha = 0
        highScoreText.fontColor = SKColor.whiteColor()
        highScoreText.zPosition = 4
        highScoreText.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2 - highScoreText.frame.size.height / 2)
        highScoreText.name = "highScoreTextEnd"
        addChild(highScoreText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
}