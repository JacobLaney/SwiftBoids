//
//  GameScene.swift
//  Birds
//
//  Created by Jake Laney on 12/15/16.
//  Copyright © 2016 Jake Laney. All rights reserved.
//

import SpriteKit
import Darwin
import GameplayKit



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var bird : Bird! // model for a bird
    
    private var toggled : Bool!
    
    override func didMove(to view: SKView) {
        toggled = false;
        
        // add a PAUSE button
        let toggle = NSButton.init(checkboxWithTitle: "Cohesion", target: self, action: #selector(togglePressed))
        toggle.state = 1
        toggle.frame = NSRect.init(x: 10, y: 10, width: 100, height: 10)
        self.view?.addSubview(toggle)
        
        // add a SPEED slider
        let slider = NSSlider(value: 250, minValue: 1, maxValue: 600, target: self, action: #selector(setSpeed))
        slider.frame = NSRect.init(x: 10, y: 50, width: 100, height: 30)
        Bird.SPEED = CGFloat(slider.floatValue)
        self.view?.addSubview(slider)
        
        self.physicsWorld.contactDelegate = self
        
        // #### uncomment for frame ####
        self.physicsBody = SKPhysicsBody.init(edgeLoopFrom: self.frame)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.restitution = 1
        self.physicsBody?.friction = 0

        // Create Bird node to use during mouse interaction
        let w : CGFloat = (self.size.width) * 0.01
        print("diameter of circle:  \(w)")
        self.bird = Bird()
        
    }
    
    func togglePressed(sender: AnyObject) {
        print("PRESSED")
        toggled = !toggled;
        if (toggled == true) {
            Bird.COHESION = 0
        }
        else {
            Bird.COHESION = 100
        }
    }
    
    func setSpeed(sender: AnyObject) {
        if let slider = sender as? NSSlider {
            Bird.SPEED = CGFloat(slider.floatValue)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.bird?.copy() as! Bird? {
            n.position = pos
            n.startMotion()
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        /********** UNCOMMENT IF NO WORLD FRAME *******
        let left : CGFloat = -1 * self.frame.width / 2
        let right : CGFloat = self.frame.width / 2
        let up : CGFloat = self.frame.height / 2
        let down : CGFloat = -1 * self.frame.height / 2
        
            for child in self.children {
                if let c = child as? Bird {
                    c.update()
                    if c.position.x < left {
                        c.position.x = right
                    }
                    else if c.position.x > right {
                        c.position.x = left
                    }
                    if c.position.y < down {
                        c.position.y = up
                    }
                    if c.position.y > up {
                        c.position.y = down
                    }
                }
            }
        ******************************************/

        for child in self.children {
            if let c = child as? Bird {
                c.update()
            }
        }
    }
    

    // contact delegate method
    func didBegin(_ contact: SKPhysicsContact) {

    }

    // contact delegate method
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
}
