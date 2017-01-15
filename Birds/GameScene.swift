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
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var bird : Bird?
    private var start : TimeInterval!
    
    let updateInterval : TimeInterval = 0.0
    
    private var toggled : Bool!
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
    
    override func didMove(to view: SKView) {
        toggled = false;
        let toggle = NSButton.init(checkboxWithTitle: "Cohesion", target: self, action: #selector(togglePressed))
        toggle.state = 1
        toggle.frame = NSRect.init(x: 10, y: 10, width: 100, height: 10)
        self.view?.addSubview(toggle)
        
        let slider = NSSlider(value: 250, minValue: 1, maxValue: 600, target: self, action: #selector(setSpeed))
        slider.frame = NSRect.init(x: 10, y: 50, width: 100, height: 30)
        Bird.SPEED = CGFloat(slider.floatValue)
        self.view?.addSubview(slider)
        
        start = 0
        
        self.physicsWorld.contactDelegate = self
        
        //self.physicsBody = SKPhysicsBody.init(edgeLoopFrom: self.frame)
        //self.physicsBody?.isDynamic = false
        //self.physicsBody?.restitution = 1
        //self.physicsBody?.friction = 0

        // Create shape node to use during mouse interaction
        let w : CGFloat = (self.size.width) * 0.01
        print("diameter of circle:  \(w)")
        
        self.bird = Bird.init(ellipseOf: CGSize.init(width: w, height: w))
        
        if let bird = self.bird {
            self.bird?.physicsBody = SKPhysicsBody.init(rectangleOf: self.bird!.frame.size)
            self.bird?.physicsBody?.affectedByGravity = false;
            self.bird?.physicsBody?.linearDamping = 0;
            self.bird?.physicsBody?.restitution = 1
            self.bird?.physicsBody?.friction = 0;
            self.bird?.physicsBody?.density = 1000;
            self.bird?.physicsBody?.angularDamping = 0;
            self.bird?.physicsBody?.contactTestBitMask = self.physicsBody!.collisionBitMask
            
            bird.lineWidth = 3.0;
            bird.strokeColor = SKColor.black;
            bird.fillColor = SKColor.black;
            bird.name = "/bird";
            
            let avoidanceField = SKShapeNode(circleOfRadius: 1.5 * w)
            avoidanceField.strokeColor = SKColor.red
            avoidanceField.lineWidth = 2.0
            self.bird?.addChild(avoidanceField)

            let scale : CGFloat = bird.frame.size.width * CGFloat(1.3 / 2)
            let field = SKShapeNode(circleOfRadius: scale)
            field.lineWidth = 0.0
            //field.strokeColor = SKColor.blue
            field.name = "field"
            bird.addChild(field)
        }
    }
    
    //SKAction.run( {bird.check(neighbors: self.birds!)} ),
    //bird.adjust()
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
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // only update every n seconds
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
    }
    
    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),
                                                SKAction.fadeOut(withDuration: 0.5)])
        
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        
        return sequence
    }()

    
    func didBegin(_ contact: SKPhysicsContact) {
        /*
        if  contact.bodyA.node! is Bird {
            contact.bodyA.velocity = CGVector.init(
                dx: contact.bodyA.velocity.dx * -1, dy: contact.bodyA.velocity.dy * -1
            )
        }
        if contact.bodyB.node! is Bird {
            contact.bodyB.velocity = CGVector.init(
                dx: contact.bodyB.velocity.dx * -1, dy: contact.bodyB.velocity.dy * -1
            )
        }
        
            let shockwave = SKShapeNode(circleOfRadius: 1)
            
            shockwave.position = contact.contactPoint
            self.addChild(shockwave)
            
            shockwave.run(shockWaveAction)
            
            let a = contact.bodyA.node! as! Bird
            let b = contact.bodyB.node! as! Bird
            
            let unitVectorA = a.unitify(a.difference(a.position, b.position))
            let unitVectorB = b.unitify(b.difference(b.position, a.position))
            let vectorA = a.scale(unitVectorA, 100)
            let vectorB = b.scale(unitVectorB, 100)
            contact.bodyA.applyImpulse(vectorA)
            contact.bodyB.applyImpulse(vectorB)
        }
        */
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
    }
}
