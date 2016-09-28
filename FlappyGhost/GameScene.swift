//
//  GameScene.swift
//  FlappyGhost
//
//  Created by Sheene Noonan on 14/03/2016.
//  Copyright (c) 2016 ShaneNoonan. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Ghost = SKSpriteNode()
    
    struct PhysicsCatagory {
        static let Ghost: UInt32 = 0x1 << 1
        static let Ground: UInt32 = 0x1 << 2
        static let Wall: UInt32 = 0x1 << 3
        static let Score: UInt32 = 0x1 << 4
        
    }
    
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    var GameStarted = Bool()
    
    var score = Int()
    let scoreLabel = SKLabelNode()
    
    var youDied = Bool()
    
    var restartButton = SKSpriteNode()
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        youDied = false
        GameStarted = false
        score = 0
        createScene()
        
    }
    
    func createScene(){
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
            
        }
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        Ground = SKSpriteNode(imageNamed: "ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        self.addChild(Ground)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        Ground.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        
        Ghost = SKSpriteNode(imageNamed: "ghost")
        Ghost.size = CGSize(width: 60, height: 70)
        Ghost.position = CGPoint(x: self.frame.width / 2 - Ghost.frame.width, y: self.frame.height / 2)
        self.addChild(Ghost)
        
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height / 2)
        Ghost.physicsBody?.categoryBitMask = PhysicsCatagory.Ghost
        Ghost.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall
        Ghost.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.isDynamic = true
        
        Ghost.zPosition = 2
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        createScene()
        
    }
    
    func createButton(){
        
        restartButton = SKSpriteNode(imageNamed: "RestartButton")
        restartButton.size = CGSize(width: 200, height: 100)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.4))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.Ghost {
            
            score += 1
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
        
        else if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Score {
            
            score += 1
            scoreLabel.text = "\(score)"
            secondBody.node?.removeFromParent()
            
        }
        
        if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Wall || firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.Ghost {
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if youDied == false {
                
                youDied = true
                createButton()
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Ground || firstBody.categoryBitMask == PhysicsCatagory.Ground && secondBody.categoryBitMask == PhysicsCatagory.Ghost {
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if youDied == false {
                
                youDied = true
                createButton()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if GameStarted == false{
            
            GameStarted = true
            
            Ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                
                self.createWalls()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let SpawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(SpawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
        }
        else {
            if youDied == true {
                
            }
            else{
                
            Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
            }
        }
        
        for touch in touches {
            let location = touch.location(in: self)
        
            if youDied == true {
                if restartButton.contains(location){
                    restartScene()
                }
            }
        
            }
    
    
    }
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "pipe")
        let bottomWall = SKSpriteNode(imageNamed: "pipe")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
        bottomWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 350)
        topWall.setScale(0.5)
        bottomWall.setScale(0.5)
        
        topWall.zRotation = CGFloat(M_PI)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.Random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
        
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if GameStarted == true{
            if youDied == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    
                    let backg = node as! SKSpriteNode
                    
                    backg.position = CGPoint(x: backg.position.x - 2, y: backg.position.y)
                    
                    if backg.position.x <= -backg.size.width {
                        backg.position = CGPoint(x: backg.position.x + backg.size.width * 2, y: backg.position.y)
                        
                    }
                    
                }))
                
            }
            
            
        }
    }
}
