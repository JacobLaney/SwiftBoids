//
//  Bird.swift
//  Birds
//
//  Created by Jake Laney on 12/15/16.
//  Copyright © 2016 Jake Laney. All rights reserved.
//

import Cocoa
import Darwin
import SpriteKit

extension CGVector {
    mutating func add(_ other: CGVector) {
        self.dx += other.dx
        self.dy += other.dy
    }
    
    static func difference(_ one: CGVector, _ two: CGVector) -> CGVector {
        return CGVector(dx: one.dx - two.dx, dy: one.dy - two.dy)
    }
}

class Bird: SKShapeNode {
    
    static var SPEED : CGFloat =  200   // * 2 pixels per second
    static var NEIGHBOR_RADIUS_SQUARED : CGFloat = 100 * 100 // radius squared
    static var COHESION : CGFloat = 100 // scalar affecting cohesion of birds to fly in the same direction
    static var REPULSION : CGFloat = 100 // scalar affecting repulsion from other objects
    static var CLOSENESS : CGFloat = 1 // scalar affecting attraction to each other
    
    override init() {
        super.init()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder);
    }
    
    func startMotion() {
        let unit_vector = unitify(CGVector.init(dx: getRandomFloat(), dy: getRandomFloat()))
        let vector = scale(unit_vector, Bird.SPEED)
        self.physicsBody?.velocity = vector
    }
    
    func smoothSpeed() {
        let unit_vector = unitify(self.physicsBody!.velocity)
        let vector = scale(unit_vector, Bird.SPEED)
        self.physicsBody?.velocity = vector
    }

    func getRandomFloat() -> CGFloat {
        let rand = Int(arc4random_uniform(100)) - 50
        return CGFloat(rand)
    }

    func differenceVector(from one: CGPoint, to two: CGPoint) -> CGVector {
        return CGVector(dx: two.x - one.x, dy: two.y - one.y)
    }
    
    func magnitude(_ vector: CGVector) -> CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
    
    func addVector(_ one: CGVector, _ two: CGVector) -> CGVector {
        return CGVector.init(
            dx: one.dx + two.dx,
            dy: one.dy + two.dy
        )
    }
    
    func squareDistance(_ one: CGPoint, _ two: CGPoint) -> CGFloat {
        return pow(one.x - two.x, 2) + pow(one.y - two.y, 2)
    }
    
    func unitify(_ vector: CGVector) -> CGVector {
        let mag = magnitude(vector)
        return CGVector.init(dx: vector.dx / mag, dy: vector.dy / mag)
    }
    
    func scale(_ vector: CGVector, _ scale: CGFloat) -> CGVector {
        return CGVector.init(dx: vector.dx * scale, dy: vector.dy * scale);
    }
    
    func update() {
        // check every bird within radius
        var neighbors = [Bird]()
        
        for child in self.parent!.children {
            if child != self {
                
                let distance = squareDistance(child.position, self.position)
                
                if distance < Bird.NEIGHBOR_RADIUS_SQUARED {
                    if child is Bird {
                        neighbors.append(child as! Bird)
                        
                        /*
                        // apply repulsion
                        if distance > pow(self.frame.width * 3.0 / 2, 2) {
                            let diff = differenceVector(from: self.position, to: child.position)
                            self.physicsBody?.velocity.add(scale(unitify(diff), Bird.CLOSENESS))
                        }
                        else if distance < pow(self.frame.width * 1.8 / 2, 2) {
                            let diff = differenceVector(from: child.position, to: self.position)
                            self.physicsBody?.velocity.add(scale(unitify(diff), Bird.REPULSION))
                        }

                        if let other = child.childNode(withName: "field") {
                            if self.childNode(withName: "field")!.intersects(other) {
                                let diff = differenceVector(from: child.position, to: self.position)
                                self.physicsBody?.velocity.add(scale(unitify(diff), REPULSION))
                            }
                        }
                        */
                    }
                }
                
                
            
                
            }
         }
        // move to average position
         // apply cohesion
        var xSum : CGFloat = 0
        var ySum : CGFloat = 0
        var dxSum : CGFloat = 0
        var dySum : CGFloat = 0
        let count : CGFloat = CGFloat(neighbors.count)
        for bird in neighbors {
            xSum += bird.position.x
            ySum += bird.position.y
            dxSum += bird.physicsBody!.velocity.dx;
            dySum += bird.physicsBody!.velocity.dy;
        }
        let point = CGPoint(x: xSum / count , y: ySum / count)
        let velocity = CGVector.init(dx: dxSum / CGFloat(neighbors.count), dy: dySum / CGFloat(neighbors.count))
        self.physicsBody!.velocity.add(scale(unitify(velocity), Bird.COHESION))
        //self.physicsBody!.velocity.add(scale(unitify(point)), 1)
        self.smoothSpeed()
    }
}
