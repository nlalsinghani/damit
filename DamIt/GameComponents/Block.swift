//
//  Block.swift
//  BlockDemo
//
//  Created by Saigaurav Purushothaman on 9/23/20.
//

import SpriteKit

//Representation of each block in the game grid
class Block: SKSpriteNode {
    var x: Int {
        didSet {
            self.updateBlock(in: self.skScene)
        }
    }
    var y: Int {
        didSet {
            self.updateBlock(in: self.skScene)
        }
    }
    var type: BlockType
    var levelDimensions: (width:Int, height:Int)
    var skScene: SKScene
    
    init(x:Int, y:Int, type:BlockType, scene:SKScene, levelDim:(width:Int, height:Int)) {
        self.x = x
        self.y = y
        self.type = type
        self.levelDimensions = levelDim
        self.skScene = scene
        
        let skin = gameSettings.skin
        var rightSkin = ""
        switch skin {
        case 1:
            rightSkin = "beaverRight"
        case 2:
            rightSkin = "beaverRight100Fancy"
        case 3:
            rightSkin = "beaverRight100Skeleton"
        default:
            rightSkin = "beaverRight"
        }
        
        let imageName = self.type == .log ? "log" : (self.type == .rock ? "rock" : (self.type == .beaver ? rightSkin : "air"))
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = self.type == .beaver ? "Beaver" : imageName.capitalized
        // maybe change zPos for air
        self.zPosition = 1.0
        self.setUpBlock(in: scene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getBlockPosition() -> (Int, Int) {
        return (self.y, self.levelDimensions.height - self.x - 1)
    }
    
    //For debugging
    func toString() -> String {
        return "X: \(self.x), Y: \(self.y), Type: \(self.type)"
    }
    
    //Prints symbol of each block - for debugging
    func blockSymbol(showPositions: Bool) -> String {
        var pos = ""
        if showPositions {
            pos.append("\(self.getBlockPosition())")
        }
        switch type {
        case .air:
            return "🟦\(pos)"
        case .log:
            return "🟫\(pos)"
        case .rock:
            return "⬜️\(pos)"
        case .beaver:
            let player = self as! Player
            let direction = player.direction
            return direction == .right ? "▶️\(pos)" : "◀️\(pos)"
        }
    }
    
    func getSkinName() -> (left: String, right: String) {
        let skin = gameSettings.skin
        var leftSkin = ""
        var rightSkin = ""
        switch skin {
        case 1:
            leftSkin = "beaverLeft"
            rightSkin = "beaverRight"
        case 2:
            leftSkin = "beaverLeft100Fancy"
            rightSkin = "beaverRight100Fancy"
        case 3:
            leftSkin = "beaverLeft100Skeleton"
            rightSkin = "beaverRight100Skeleton"
        default:
            leftSkin = "beaverLeft"
            rightSkin = "beaverRight"
        }
        return (leftSkin, rightSkin)
    }
}

extension Block {
    func setUpBlock(in scene: SKScene) {
        if self.type == .air {
            self.removeFromParent()
            return
        }
        let xPad: CGFloat = (scene.frame.width - (CGFloat(levelDimensions.width) * self.frame.width)) / 2.0 + self.frame.size.width / 2.0
        let yPad: CGFloat = 490
        let blockPos: (x:Int, y:Int) = self.getBlockPosition()
        self.position = CGPoint(x: xPad + CGFloat(blockPos.x) * self.frame.width, y: yPad + CGFloat(blockPos.y) * self.frame.height)
        // Physics
        self.physicsBody?.categoryBitMask = blockBitMask
        self.physicsBody?.collisionBitMask = beaverBitMask | victoryTextBitMask
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.texture!.size())
        self.physicsBody?.isDynamic = false
//        self.physicsBody?.affectedByGravity = true
        scene.addChild(self)
    }
    
    func updateBlock(in scene: SKScene) {
        let xPad: CGFloat = (scene.frame.width - (CGFloat(levelDimensions.width) * self.frame.width)) / 2.0 + self.frame.size.width / 2.0
        let yPad: CGFloat = 490
        let blockPos: (x:Int, y:Int) = self.getBlockPosition()
        self.position = CGPoint(x: xPad + CGFloat(blockPos.x) * self.frame.width, y: yPad + CGFloat(blockPos.y) * self.frame.height)
        if self is Player {
            let beaver = self as! Player
            let skinName = getSkinName()
            let imageName = beaver.direction == .right ? skinName.right : skinName.left
            beaver.texture = SKTexture(imageNamed: imageName)
        }
    }
    
    func activateGravity() {
        self.physicsBody?.isDynamic = true
    }
}
