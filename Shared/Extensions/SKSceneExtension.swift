//
//  SKSceneExtension.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 13/01/16.
//  Copyright © 2016 YaLu. All rights reserved.
//

import SpriteKit

class SKSceneExtension: SKScene {
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.location(in: self)
            screenInteractionStarted(location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.location(in: self)
            screenInteractionMoved(location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.location(in: self)
            screenInteractionEnded(location)
        }
    }
    #endif
    
    #if os(OSX)
    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        screenInteractionStarted(location)
    }
    override func mouseDragged(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        screenInteractionMoved(location)
    }
    override func mouseUp(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        screenInteractionEnded(location)
    }
    #endif
    
    func screenInteractionStarted(_ location: CGPoint) {
    }
    
    func screenInteractionMoved(_ location: CGPoint) {
    }
    
    func screenInteractionEnded(_ location: CGPoint) {
    }
    
}
