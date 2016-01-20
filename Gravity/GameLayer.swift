//
//  GameLayer.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 13/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//


import SpriteKit

class GameLayer: SKNode {
    
    //Actions
    var topBarInAction:SKAction = SKAction()
    var bottomBarInAction:SKAction = SKAction()
    var scoreNodeInAction:SKAction = SKAction()
    
    //Nodes
    var topBar:SKShapeNode = SKShapeNode()
    var bottomBar:SKShapeNode = SKShapeNode()
    var player:SKShapeNode = SKShapeNode()
    var scoreNode = SKLabelNode()
    
    override init() {
        super.init()
        
        topBarInAction = SKAction.moveToY(vars.screenSize.height - vars.barHeight / 2, duration: vars.gameLayerFadeTime)
        
        bottomBarInAction = SKAction.moveToY(vars.barHeight / 2, duration: vars.gameLayerFadeTime)
        
        topBar = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.width, height: vars.barHeight))
        topBar.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height + vars.barHeight / 2)
        topBar.zPosition = 2
        addChild(topBar)
        
        bottomBar = SKShapeNode(rectOfSize: CGSize(width: vars.screenSize.width, height: vars.barHeight))
        bottomBar.position = CGPoint(x: vars.screenSize.width / 2, y: -(vars.barHeight / 2))
        bottomBar.zPosition = 2
        addChild(bottomBar)
        
        player = SKShapeNode(circleOfRadius: vars.screenSize.height / 28)
        player.position = CGPoint(x: vars.screenSize.width / 2, y: vars.screenSize.height / 2)
        player.fillColor = colors.playerColor
        player.strokeColor = colors.playerColor
        player.zPosition = 2
        addChild(player)
        
        scoreNode = SKLabelNode(fontNamed: "Helvetia")
        scoreNode.text = "00:00.00"
        scoreNode.fontSize = 28
        scoreNode.fontColor = SKColor.whiteColor()
        scoreNode.horizontalAlignmentMode = .Right
        scoreNode.zPosition = 2
        scoreNode.position = CGPoint(x: scoreNode.frame.width + vars.screenSize.width / 60, y: vars.screenSize.height + scoreNode.frame.height + vars.screenSize.height / 40)
        scoreNode.name = "scoreNode"
        addChild(scoreNode)
        
        scoreNodeInAction = SKAction.moveToY(vars.screenSize.height - scoreNode.frame.height - vars.screenSize.height / 40, duration: vars.gameLayerFadeTime)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
    
}
