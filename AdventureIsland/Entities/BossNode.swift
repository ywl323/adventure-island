import SpriteKit

class BossNode: SKNode {

    // MARK: - 属性
    private var bossType: String = ""
    private var health: Int = 3
    private var damage: Int = 1
    private var scoreValue: Int = 500
    private var sprite: SKSpriteNode!
    private var isVulnerable: Bool = true

    // Boss 状态
    private var isAttacking: Bool = false
    private var isHurt: Bool = false

    // PNG 映射
    private static let typeToImage: [String: String] = [
        "boss_raptor": "06_boss_raptor",
        "boss_frog": "07_boss_frog",
        "boss_lava": "08_boss_lava_dragon",
        "boss_dark": "09_boss_dark_dragon"
    ]

    // 精灵尺寸
    private var spriteSize: CGSize = CGSize(width: 120, height: 120)

    // MARK: - 初始化

    init(type: String) {
        self.bossType = type
        super.init()
        configureByType()
        setupAppearance()
        setupPhysics()
        startBossAI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureByType() {
        switch bossType {
        case "boss_raptor":
            health = 3; damage = 1; scoreValue = 500
            spriteSize = CGSize(width: 100, height: 90)
        case "boss_frog":
            health = 4; damage = 1; scoreValue = 600
            spriteSize = CGSize(width: 110, height: 80)
        case "boss_lava":
            health = 5; damage = 2; scoreValue = 800
            spriteSize = CGSize(width: 130, height: 100)
        case "boss_dark":
            health = 6; damage = 2; scoreValue = 1000
            spriteSize = CGSize(width: 140, height: 110)
        default:
            health = 3; damage = 1; scoreValue = 500
            spriteSize = CGSize(width: 100, height: 100)
        }
    }

    private func setupAppearance() {
        let imageName = BossNode.typeToImage[bossType] ?? "09_boss_dark_dragon"
        print("👹 Boss[\(bossType)]: loading '\(imageName)'")

        let texture = SKTexture(imageNamed: imageName)
        print("   texture size: \(texture.size())")

        if texture.size().width == 0 {
            print("❌ Boss[\(bossType)]: texture '\(imageName)' FAILED to load — using placeholder")
            sprite = SKSpriteNode(color: .purple, size: spriteSize)
        } else {
            sprite = SKSpriteNode(texture: texture, size: spriteSize)
            print("✅ Boss[\(bossType)]: loaded texture '\(imageName)'")
        }

        sprite.position = .zero
        addChild(sprite)
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: spriteSize)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategories.enemy
        physicsBody?.contactTestBitMask = PhysicsCategories.player
        physicsBody?.collisionBitMask = PhysicsCategories.ground
        physicsBody?.allowsRotation = false
    }

    // MARK: - Boss AI

    private func startBossAI() {
        // Boss 待机动画 + 随机移动
        let idle = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in self?.bossMove() }
        ])
        run(SKAction.repeatForever(idle))
    }

    private func bossMove() {
        guard !isHurt else { return }

        // 在 1000~2500 范围内左右移动
        let rangeMin: CGFloat = 1000
        let rangeMax: CGFloat = 2500

        let randomX = CGFloat.random(in: rangeMin...rangeMax)
        let duration = TimeInterval.random(in: 1.0...2.0)
        let move = SKAction.moveTo(x: randomX, duration: duration)

        // 移动时翻转方向
        let flip = SKAction.run { [weak self] in
            if let self = self {
                self.xScale = randomX > self.position.x ? abs(self.xScale) : -abs(self.xScale)
            }
        }

        run(SKAction.sequence([flip, move]))
    }

    // MARK: - 受伤

    func takeDamage(_ amount: Int = 1) {
        guard isVulnerable && !isHurt else { return }

        isHurt = true
        health -= amount

        // 受伤闪烁
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.1)
        ])
        sprite.run(flash)

        // 短暂无敌
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isHurt = false
        }

        // 受伤时后退
        let knockback = SKAction.moveBy(x: xScale > 0 ? -50 : 50, y: 20, duration: 0.3)
        run(knockback)

        if health <= 0 {
            die()
        }
    }

    func die() {
        // Boss 死亡动画
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.5)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([fadeOut, scaleUp, remove]))
    }

    // MARK: - 与玩家碰撞

    func getDamage() -> Int {
        return damage
    }

    func getHealth() -> Int {
        return health
    }

    func isAlive() -> Bool {
        return health > 0 && parent != nil
    }
}