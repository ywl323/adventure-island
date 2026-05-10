import SpriteKit

class Item: SKNode {

    // MARK: - 属性
    private var itemType: String = "coin"
    private var value: Int = 10

    private var body: SKShapeNode!

    // MARK: - 初始化

    init(type: String) {
        self.itemType = type
        super.init()
        configureByType()
        setupAppearance()
        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureByType() {
        switch itemType {
        case "coin":
            value = 10
        case "fruit", "apple", "banana", "grape":
            value = 20
        case "egg":
            value = 50
        case "health", "heart", "red_heart":
            value = 0 // 回血
        case "diamond":
            value = 100
        case "powerup":
            value = 0 // 能力提升道具
        default:
            value = 10
        }
    }

    private func setupAppearance() {
        let size: CGSize
        let color: SKColor
        let shapeType: String

        switch itemType {
        case "coin", "gold":
            size = CGSize(width: 30, height: 30)
            color = SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
            shapeType = "circle"
        case "fruit", "apple":
            size = CGSize(width: 28, height: 28)
            color = SKColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0)
            shapeType = "circle"
        case "banana":
            size = CGSize(width: 32, height: 24)
            color = SKColor(red: 0.95, green: 0.9, blue: 0.3, alpha: 1.0)
            shapeType = "oval"
        case "grape":
            size = CGSize(width: 30, height: 30)
            color = SKColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0)
            shapeType = "circle"
        case "egg":
            size = CGSize(width: 26, height: 32)
            color = SKColor(white: 0.95, alpha: 1.0)
            shapeType = "oval"
        case "heart", "health", "red_heart":
            size = CGSize(width: 32, height: 28)
            color = SKColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0)
            shapeType = "heart"
        case "diamond":
            size = CGSize(width: 30, height: 30)
            color = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
            shapeType = "diamond"
        case "powerup", "star":
            size = CGSize(width: 35, height: 35)
            color = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
            shapeType = "star"
        case "coconut":
            size = CGSize(width: 30, height: 30)
            color = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
            shapeType = "circle"
        case "crystal":
            size = CGSize(width: 28, height: 35)
            color = SKColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0)
            shapeType = "diamond"
        default:
            size = CGSize(width: 28, height: 28)
            color = SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
            shapeType = "circle"
        }

        // 根据形状类型创建不同的节点
        switch shapeType {
        case "circle":
            body = SKShapeNode(circleOfRadius: size.width / 2)
        case "oval":
            body = SKShapeNode(ellipseOf: size)
        case "heart":
            body = createHeartNode(size: size)
        case "diamond":
            body = createDiamondNode(size: size)
        case "star":
            body = createStarNode(size: size)
        default:
            body = SKShapeNode(circleOfRadius: size.width / 2)
        }

        body.fillColor = color
        body.strokeColor = .white
        body.lineWidth = 2
        addChild(body)

        // 设置物理体
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategories.item
        physicsBody?.contactTestBitMask = PhysicsCategories.player
    }

    private func createHeartNode(size: CGSize) -> SKShapeNode {
        let path = CGMutablePath()
        let w = size.width
        let h = size.height

        path.move(to: CGPoint(x: w/2, y: h * 0.3))
        path.addCurve(to: CGPoint(x: w/2, y: h * 0.1),
                      control1: CGPoint(x: w * 0.1, y: h * 0.1),
                      control2: CGPoint(x: w * 0.1, y: h * 0.3))
        path.addCurve(to: CGPoint(x: w/2, y: h * 0.7),
                      control1: CGPoint(x: w * 0.1, y: h * 0.5),
                      control2: CGPoint(x: w/2, y: h * 0.6))
        path.addCurve(to: CGPoint(x: w * 0.8, y: h * 0.2),
                      control1: CGPoint(x: w * 0.7, y: h * 0.4),
                      control2: CGPoint(x: w * 0.8, y: h * 0.3))
        path.addCurve(to: CGPoint(x: w/2, y: h * 0.3),
                      control1: CGPoint(x: w * 0.9, y: h * 0.1),
                      control2: CGPoint(x: w * 0.7, y: h * 0.1))

        let node = SKShapeNode(path: path)
        return node
    }

    private func createDiamondNode(size: CGSize) -> SKShapeNode {
        let path = CGMutablePath()
        let w = size.width
        let h = size.height

        path.move(to: CGPoint(x: w/2, y: 0))
        path.addLine(to: CGPoint(x: w, y: h/2))
        path.addLine(to: CGPoint(x: w/2, y: h))
        path.addLine(to: CGPoint(x: 0, y: h/2))
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        return node
    }

    private func createStarNode(size: CGSize) -> SKShapeNode {
        let path = CGMutablePath()
        let cx = size.width / 2
        let cy = size.height / 2
        let outerR = size.width / 2
        let innerR = outerR * 0.4
        let points = 5

        for i in 0..<(points * 2) {
            let r = (i % 2 == 0) ? outerR : innerR
            let angle = (CGFloat(i) * .pi / CGFloat(points)) - .pi / 2
            let x = cx + r * cos(angle)
            let y = cy + r * sin(angle)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        let node = SKShapeNode(path: path)
        return node
    }

    // MARK: - 收集逻辑

    func collect() {
        // 收集动画
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([scaleUp, fadeOut, remove]))
    }

    // MARK: - 闲置动画

    private func startIdleAnimation() {
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 0.6),
            SKAction.moveBy(x: 0, y: -5, duration: 0.6)
        ])
        let rotate = SKAction.sequence([
            SKAction.rotate(byAngle: .pi * 0.1, duration: 0.3),
            SKAction.rotate(byAngle: -.pi * 0.2, duration: 0.6),
            SKAction.rotate(byAngle: .pi * 0.1, duration: 0.3)
        ])
        run(SKAction.group([bounce, SKAction.repeatForever(rotate)]))
    }

    // MARK: - 获取属性

    func getValue() -> Int {
        return value
    }

    func getType() -> String {
        return itemType
    }

    func isHealthItem() -> Bool {
        return itemType == "health" || itemType == "heart" || itemType == "red_heart"
    }
}