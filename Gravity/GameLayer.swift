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
    var menuNodeInAction:SKAction = SKAction()
    
    //Nodes
    var topBar:SKShapeNode = SKShapeNode()
    var bottomBar:SKShapeNode = SKShapeNode()
    var player:SKShapeNode = SKShapeNode()
    var scoreNode = SKLabelNode()
    var menuNode = SKSpriteNode()
    
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
        scoreNode.fontSize = vars.screenSize.height / 13
        scoreNode.fontColor = SKColor.whiteColor()
        scoreNode.horizontalAlignmentMode = .Left
        scoreNode.zPosition = 2
        scoreNode.position = CGPoint(x: vars.screenSize.width / 60, y: vars.screenSize.height + scoreNode.frame.height + vars.screenSize.height / 40)
        scoreNode.name = "scoreNode"
        addChild(scoreNode)
        
        scoreNodeInAction = SKAction.moveToY(vars.screenSize.height - scoreNode.frame.height / 2 - (vars.screenSize.height / 7) / 2, duration: vars.gameLayerFadeTime)
        
        menuNode = SKSpriteNode(imageNamed: "GameCenter.png")
        menuNode.setScale(vars.screenSize.height / 320)
        menuNode.position = CGPoint(x: vars.screenSize.width / 2 - menuNode.frame.size.width / 2, y: vars.screenSize.height + menuNode.frame.size.height + vars.screenSize.height / 40)
        menuNode.zPosition = 4
        menuNode.name = "menuNode"
        addChild(menuNode)
        
        menuNodeInAction = SKAction.moveToY(vars.screenSize.height - ((vars.screenSize.height / 7) / 2), duration: vars.gameLayerFadeTime)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
