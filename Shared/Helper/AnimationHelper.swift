//
//  AnimationHelper.swift
//  Gravity
//
//  Created by Yannik Lauenstein on 07/11/2016.
//  Copyright © 2016 YaLu. All rights reserved.
//

import Foundation
import SpriteKit

class AnimationHelper {
    
    func getPulsingAction(factor: CGFloat) -> SKAction {
        let pulseUp = SKAction.scale(to: factor + 0.02, duration: 2.0)
        let pulseDown = SKAction.scale(to: factor - 0.02, duration: 2.0)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        return repeatPulse
    }
}
