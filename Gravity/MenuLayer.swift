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
    var playButton = SKShapeNode()
    var playArrow = SKShapeNode()
    var highScoreNode = SKLabelNode()
    var GCNode = SKShapeNode()
    
    override init() {
        super.init()
        
        backgroundNode = SKShapeNode(rectOfSize: interScene.screenSize)
        backgroundNode.position = CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height / 2)
        backgroundNode.fillColor = colors.blueBGColor
        backgroundNode.strokeColor = colors.blueBGColor
        backgroundNode.zPosition = 1
        addChild(backgroundNode)
        
        playButton = SKShapeNode(circleOfRadius: interScene.screenSize.height / 8)
        playButton.position = CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height / 2)
        playButton.fillColor = colors.playerColor
        playButton.strokeColor = colors.playerColor
        playButton.zPosition = 2
        playButton.name = "playButton"
        addChild(playButton)
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, -(interScene.screenSize.width / 40), -(interScene.screenSize.height / 20))
        CGPathAddLineToPoint(path, nil, -(interScene.screenSize.width / 40), interScene.screenSize.height / 20)
        CGPathAddLineToPoint(path, nil, interScene.screenSize.width / 40, 0)
        CGPathCloseSubpath(path)
        playArrow = SKShapeNode(path: path, centered: true)
        playArrow.lineWidth = 0
        playArrow.fillColor = colors.blueBarColor
        playArrow.strokeColor = colors.blueBarColor
        playArrow.zPosition = 3
        playArrow.name = "playArrow"
        playArrow.position = CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height / 2)
        addChild(playArrow)
        
        highScoreNode = SKLabelNode(fontNamed: "Helvetia")
        highScoreNode.text = "0.00"
        highScoreNode.fontSize = 28
        highScoreNode.fontColor = SKColor.whiteColor()
        highScoreNode.zPosition = 2
        highScoreNode.position = CGPoint(x: interScene.screenSize.width - highScoreNode.frame.width - interScene.screenSize.width / 60, y: interScene.screenSize.height - highScoreNode.frame.height - interScene.screenSize.height / 40)
        highScoreNode.name = "highScoreNode"
        addChild(highScoreNode)
        
        GCNode = SKShapeNode(rectOfSize: CGSize(width: interScene.screenSize.height / 10, height: interScene.screenSize.height / 10), cornerRadius: 1)
        GCNode.position = CGPoint(x: GCNode.frame.size.width / 2 + interScene.screenSize.width / 40, y: interScene.screenSize.height - GCNode.frame.size.height )//- interScene.screenSize.height / 40)
        GCNode.fillColor = SKColor.whiteColor()
        GCNode.strokeColor = SKColor.whiteColor()
        GCNode.zPosition = 2
        GCNode.name = "GCNode"
        addChild(GCNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
    
}
