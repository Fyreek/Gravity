//
//  GameViewController.swift
//  Gravity
//
//  Created by Luca Friedrich on 13/01/2016.
//  Copyright (c) 2016 YaLu. All rights reserved.
//

import UIKit
import SpriteKit
import EasyGameCenter

class GameViewController: UIViewController, EGCDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        EGC.sharedInstance(self)
        self.view.multipleTouchEnabled = true
        //EGC.showLoginPage = false

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.showsPhysics = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.size = skView.bounds.size
            
            skView.presentScene(scene)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "shareHighscore", name: "shareHighscore", object: nil)
            
        }
    }
    
    func EGCAuthentified(authentified:Bool) {
        if authentified {
            vars.gameCenterLoggedIn = true
            EGC.getHighScore(leaderboardIdentifier: "gravity_leaderboard") {
                (tupleHighScore) -> Void in
                if let tupleIsOk = tupleHighScore {
                    if vars.highscoreGC < Float(tupleIsOk.score) / 100 {
                        
                    vars.highscoreGC = Float(tupleIsOk.score) / 100
                        
                    NSUserDefaults.standardUserDefaults().setFloat(Float(vars.highscoreGC), forKey: "highscore")
                    NSUserDefaults.standardUserDefaults().synchronize()
                        
                    }
                    
                }
            }
        }
    }
    
    func shareHighscore() {
        
        let sharingText = "I've survived for " + ((NSString(format: "%.02f", vars.highscoreGC)) as String) + " seconds in Gr4vity. Can you beat me?\nhttp://apple.co/1P2rkrT"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [sharingText], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }


    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
