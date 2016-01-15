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
        
        topBarInAction = SKAction.moveToY(interScene.screenSize.height - interScene.barHeight / 2, duration: interScene.gameLayerFadeTime)
        
        bottomBarInAction = SKAction.moveToY(interScene.barHeight / 2, duration: interScene.gameLayerFadeTime)
        
        topBar = SKShapeNode(rectOfSize: CGSize(width: interScene.screenSize.width, height: interScene.barHeight))
        topBar.position = CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height + interScene.barHeight / 2)
        topBar.fillColor = colors.blueBarColor
        topBar.strokeColor = colors.blueBarColor
        topBar.zPosition = 2
        addChild(topBar)
        
        bottomBar = SKShapeNode(rectOfSize: CGSize(width: interScene.screenSize.width, height: interScene.barHeight))
        bottomBar.position = CGPoint(x: interScene.screenSize.width / 2, y: -(interScene.barHeight / 2))
        bottomBar.fillColor = colors.blueBarColor
        bottomBar.strokeColor = colors.blueBarColor
        bottomBar.zPosition = 2
        addChild(bottomBar)
        
        player = SKShapeNode(circleOfRadius: interScene.screenSize.height / 24)
        player.position = CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height / 2)
        player.fillColor = colors.playerColor
        player.strokeColor = colors.playerColor
        player.zPosition = 2
        addChild(player)
        
        scoreNode = SKLabelNode(fontNamed: "Helvetia")
        scoreNode.text = "0.00"
        scoreNode.fontSize = 28
        scoreNode.fontColor = SKColor.whiteColor()
        scoreNode.zPosition = 2
        scoreNode.position = CGPoint(x: scoreNode.frame.width + interScene.screenSize.width / 60, y: interScene.screenSize.height + scoreNode.frame.height + interScene.screenSize.height / 40)
        scoreNode.name = "scoreNode"
        addChild(scoreNode)
        
        scoreNodeInAction = SKAction.moveToY(interScene.screenSize.height - scoreNode.frame.height - interScene.screenSize.height / 40, duration: interScene.gameLayerFadeTime)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
    
}
