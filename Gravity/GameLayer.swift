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
    
    //Nodes
    var topBar:SKShapeNode = SKShapeNode()
    var bottomBar:SKShapeNode = SKShapeNode()
    var player:SKShapeNode = SKShapeNode()
    
    override init() {
        super.init()
        
        topBarInAction = SKAction.moveToY(interScene.screenSize.height - interScene.barHeight / 2, duration: interScene.gameLayerFadeTime)
        
        bottomBarInAction = SKAction.moveToY(interScene.barHeight / 2, duration: interScene.gameLayerFadeTime)
        
        topBar = SKShapeNode(rectOfSize: CGSize(width: interScene.screenSize.width, height: interScene.barHeight))
        topBar.position = CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height + interScene.barHeight / 2)
        topBar.fillColor = SKColor(red: 83 / 255, green: 88 / 255, blue: 128 / 255, alpha: 1)
        topBar.strokeColor = SKColor(red: 83 / 255, green: 88 / 255, blue: 128 / 255, alpha: 1)
        topBar.zPosition = 2
        addChild(topBar)
        
        
        
        bottomBar = SKShapeNode(rectOfSize: CGSize(width: interScene.screenSize.width, height: interScene.barHeight))
        bottomBar.position = CGPoint(x: interScene.screenSize.width / 2, y: -(interScene.barHeight / 2))
        bottomBar.fillColor = SKColor(red: 83 / 255, green: 88 / 255, blue: 128 / 255, alpha: 1)
        bottomBar.strokeColor = SKColor(red: 83 / 255, green: 88 / 255, blue: 128 / 255, alpha: 1)
        bottomBar.zPosition = 2
        addChild(bottomBar)
        
        player = SKShapeNode(circleOfRadius: interScene.screenSize.height / 16)
        player.position = CGPoint(x: interScene.screenSize.width / 2, y: interScene.screenSize.height / 2)
        player.fillColor = SKColor.whiteColor()
        player.strokeColor = SKColor.whiteColor()
        player.zPosition = 2
        addChild(player)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
    
}
