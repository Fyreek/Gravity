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
    var playArrow = SKShapeNode()
    var highScoreNode = SKLabelNode()
    var GCNode = SKSpriteNode()
    
    override init() {
        super.init()
        
        backgroundNode = SKShapeNode(rectOfSize: vars.screenSize)
        backgroundNode.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        backgroundNode.zPosition = 1
        addChild(backgroundNode)
        
        playButton = SKSpriteNode(imageNamed: "PlayButton.png")
        playButton.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        playButton.zPosition = 2
        playButton.name = "playButton"
        addChild(playButton)
        
        highScoreNode = SKLabelNode(fontNamed: "Helvetia")
        highScoreNode.text = "00:00.00"
        highScoreNode.fontSize = 28
        highScoreNode.fontColor = SKColor.whiteColor()
        highScoreNode.zPosition = 2
        highScoreNode.position = CGPoint(x: vars.screenSize.width - highScoreNode.frame.width - vars.screenSize.width / 60, y: vars.screenSize.height - highScoreNode.frame.height - vars.screenSize.height / 40)
        highScoreNode.name = "highScoreNode"
        addChild(highScoreNode)
        
        GCNode = SKSpriteNode(imageNamed: "GameCenter.png")
        GCNode.position = CGPoint(x: GCNode.frame.size.width / 2 + vars.screenSize.width / 66, y: (vars.screenSize.height - (vars.screenSize.height / 2 - GCNode.frame.size.height / 2) / 6 ))//- vars.screenSize.height / 40)
        GCNode.zPosition = 4
        GCNode.name = "GCNode"
        addChild(GCNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
    
}
