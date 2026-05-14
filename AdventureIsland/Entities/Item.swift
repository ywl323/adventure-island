import SpriteKit

class Item: SKNode {

    // MARK: - 属性
    private var itemType: String = "coin"
    private var value: Int = 10
    private var sprite: SKSpriteNode!

    // PNG 文件名映射
    private static let typeToImage: [String: String] = [
        "coin": "10_item_coin",
        "gold": "10_item_coin",
        "apple": "11_item_apple",
        "fruit": "11_item_apple",
        "banana": "12_item_banana",
        "grape": "17_item_grape",
        "egg": "13_item_egg",
        "heart": "14_item_heart",
        "health": "14_item_heart",
        "red_heart": "14_item_heart",
        "diamond": "15_item_diamond",
        "star": "16_item_star",
        "powerup": "16_item_star",
        "coconut": "11_item_apple",
        "crystal": "15_item_diamond"
    ]

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
        case "heart", "health", "red_heart":
            value = 0
        case "diamond":
            value = 100
        case "powerup", "star":
            value = 0
        default:
            value = 10
        }
    }

    private func setupAppearance() {
        let imageName = Item.typeToImage[itemType] ?? "10_item_coin"
        let texture = SKTexture(imageNamed: imageName)
        sprite = SKSpriteNode(texture: texture, size: CGSize(width: 35, height: 35))
        sprite.position = .zero
        addChild(sprite)

        physicsBody = SKPhysicsBody(circleOfRadius: 17)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategories.item
        physicsBody?.contactTestBitMask = PhysicsCategories.player
    }

    // MARK: - 收集逻辑

    func collect() {
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
