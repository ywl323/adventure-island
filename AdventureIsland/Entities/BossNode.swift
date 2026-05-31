import SpriteKit

class BossNode: SKNode {

    // MARK: - 公开属性
    var hp: Int { health }
    var maxHP: Int { _maxHP }
    var isDefeated: Bool { health <= 0 || parent == nil }

    // MARK: - 私有属性
    private var bossType: String = ""
    private var _maxHP: Int = 3
    private var health: Int = 3
    private var damage: Int = 1
    private var scoreValue: Int = 500
    private var sprite: SKSpriteNode!
    private var isVulnerable: Bool = true

    private var isAttacking: Bool = false
    private var isHurt: Bool = false
    private var playerPosition: CGPoint = .zero

    // PNG 映射（使用共享 EntityTypeMapping）

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
            _maxHP = 3; health = 3; damage = 1; scoreValue = 500
            spriteSize = CGSize(width: 100, height: 90)
        case "boss_frog":
            _maxHP = 4; health = 4; damage = 1; scoreValue = 600
            spriteSize = CGSize(width: 110, height: 80)
        case "boss_lava":
            _maxHP = 5; health = 5; damage = 2; scoreValue = 800
            spriteSize = CGSize(width: 130, height: 100)
        case "boss_dark":
            _maxHP = 6; health = 6; damage = 2; scoreValue = 1000
            spriteSize = CGSize(width: 140, height: 110)
        default:
            _maxHP = 3; health = 3; damage = 1; scoreValue = 500
            spriteSize = CGSize(width: 100, height: 100)
        }
    }

    private func setupAppearance() {
        let imageName = EntityTypeMapping.boss[bossType] ?? "09_boss_dark_dragon"

        // 使用纹理缓存
        let texture = TextureCache.shared.texture(for: imageName)
        if texture.size().width == 0 {
            sprite = SKSpriteNode(color: .purple, size: spriteSize)
        } else {
            sprite = SKSpriteNode(texture: texture, size: spriteSize)
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
        let idle = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in self?.bossMove() }
        ])
        run(SKAction.repeatForever(idle))
    }

    private func bossMove() {
        guard !isHurt else { return }
        let rangeMin: CGFloat = 1000
        let rangeMax: CGFloat = 2500
        let randomX = CGFloat.random(in: rangeMin...rangeMax)
        let duration = TimeInterval.random(in: 1.0...2.0)
        let move = SKAction.moveTo(x: randomX, duration: duration)
        let flip = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.xScale = randomX > self.position.x ? abs(self.xScale) : -abs(self.xScale)
        }
        run(SKAction.sequence([flip, move]))
    }

    // MARK: - 更新（每帧由 BossScene 调用）

    func update(playerPosition: CGPoint) {
        self.playerPosition = playerPosition

        // Boss AI：追踪玩家（缓慢靠近）
        if !isHurt && !isDefeated {
            let dx = playerPosition.x - position.x
            let speed: CGFloat = 60

            if abs(dx) > 150 {
                let direction: CGFloat = dx > 0 ? 1 : -1
                position.x += direction * speed * (1.0 / 60.0)

                // 翻转朝向
                if direction > 0 {
                    xScale = abs(xScale)
                } else {
                    xScale = -abs(xScale)
                }
            }
        }
    }

    // MARK: - 受伤

    func takeDamage(_ amount: Int = 1) {
        guard isVulnerable && !isHurt && !isDefeated else { return }

        isHurt = true
        health -= amount

        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        sprite.run(flash)

        let knockback = SKAction.moveBy(x: xScale > 0 ? -50 : 50, y: 20, duration: 0.3)
        run(knockback)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isHurt = false
        }

        if health <= 0 {
            die()
        }
    }

    func die() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.5)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([fadeOut, scaleUp, remove]))
    }

    // MARK: - 碰撞/攻击判定

    /// 安全的攻击判定框，考虑 xScale/yScale 翻转
    var attackHitbox: CGRect {
        let scaledWidth = spriteSize.width * abs(xScale)
        let scaledHeight = spriteSize.height * abs(yScale)
        let offsetX = xScale < 0 ? spriteSize.width / 2 : -spriteSize.width / 2
        return CGRect(
            x: position.x + offsetX,
            y: position.y - scaledHeight / 2,
            width: scaledWidth,
            height: scaledHeight
        )
    }

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