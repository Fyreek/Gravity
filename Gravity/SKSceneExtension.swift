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
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.locationInNode(self)
            screenInteractionStarted(location)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.locationInNode(self)
            screenInteractionMoved(location)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.locationInNode(self)
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
    
    func screenInteractionStarted(location: CGPoint) {
    }
    
    func screenInteractionMoved(location: CGPoint) {
    }
    
    func screenInteractionEnded(location: CGPoint) {
    }
    
}
