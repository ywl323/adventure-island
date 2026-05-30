import SpriteKit

class Enemy: SKNode {

    // MARK: - 属性
    private var enemyType: String = "basic"
    private var health: Int = 1
    private var moveSpeed: CGFloat = 100
    private var damage: Int = 1
    private var scoreValue: Int = 100
    private var sprite: SKSpriteNode!

    // 移动方向
    private var direction: CGFloat = 1

    // 巡逻边界（世界坐标）
    private var patrolMinX: CGFloat = 0
    private var patrolMaxX: CGFloat = 0

    // 精灵尺寸
    private var spriteSize: CGSize = CGSize(width: 50, height: 50)

    // MARK: - 初始化

    init(type: String) {
        self.enemyType = type
        super.init()
        configureByType()
        setupAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureByType() {
        switch enemyType {
        case "dinosaur", "snail", "seagull":
            health = 1; moveSpeed = 80; damage = 1; scoreValue = 100
        case "bee", "lizard", "snake", "skeleton":
            health = 1; moveSpeed = 120; damage = 1; scoreValue = 150
        case "bat", "scorpion":
            health = 2; moveSpeed = 100; damage = 1; scoreValue = 200
        case "fire_lizard", "fire_skeleton", "volcanic_bat", "magma_sprite":
            health = 2; moveSpeed = 140; damage = 2; scoreValue = 250
        case "storm_vulture", "lightning_lizard":
            health = 2; moveSpeed = 160; damage = 2; scoreValue = 300
        case "guardian_statue", "curse_ghost":
            health = 3; moveSpeed = 60; damage = 2; scoreValue = 400
        case "sky_knight", "guardian_angel":
            health = 3; moveSpeed = 180; damage = 2; scoreValue = 350
        case "worm", "fire_beetle", "magma_ghost", "magma_golem":
            health = 3; moveSpeed = 100; damage = 2; scoreValue = 300
        case "thunder_orb":
            health = 2; moveSpeed = 200; damage = 2; scoreValue = 350
        case "piranha":
            health = 1; moveSpeed = 150; damage = 1; scoreValue = 150
        case "raptor":
            health = 2; moveSpeed = 120; damage = 2; scoreValue = 300
        case "frog":
            health = 2; moveSpeed = 80; damage = 1; scoreValue = 200
        case "lava_dragon", "dark_dragon":
            health = 3; moveSpeed = 100; damage = 2; scoreValue = 500
        default:
            health = 1; moveSpeed = 100; damage = 1; scoreValue = 100
        }
    }

    private func setupAppearance() {
        let imageName = EntityTypeMapping.enemy[enemyType] ?? "02_enemy_dinosaur"
        let texture = TextureCache.shared.texture(for: imageName)
        if texture.size().width == 0 {
            sprite = SKSpriteNode(color: .red, size: spriteSize)
        } else {
            let displaySize = CGSize(width: 50, height: 50)
            sprite = SKSpriteNode(texture: texture, size: displaySize)
        }
        sprite.position = .zero
        addChild(sprite)
        setupPhysics()
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: spriteSize)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategories.enemy
        physicsBody?.contactTestBitMask = PhysicsCategories.player
        physicsBody?.collisionBitMask = PhysicsCategories.ground
        physicsBody?.allowsRotation = false
        let flyingTypes = ["bat", "volcanic_bat", "storm_vulture", "sky_knight", "guardian_angel", "thunder_orb"]
        physicsBody?.affectedByGravity = !flyingTypes.contains(enemyType)
    }

    /// 由 GameScene 在所有敌人创建完毕并设置巡逻边界后统一调用
    /// 避免在 init() 中过早启动，导致边界尚未设置就乱走
    func startPatrolling() {
        let wait = SKAction.wait(forDuration: TimeInterval.random(in: 1.5...3.0))
        let move = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.patrolMaxX > self.patrolMinX {
                if self.position.x >= self.patrolMaxX {
                    self.direction = -1
                } else if self.position.x <= self.patrolMinX {
                    self.direction = 1
                }
            }
            let moveDistance = self.direction * self.moveSpeed * 0.5
            let moveAction = SKAction.moveBy(x: moveDistance, y: 0, duration: 0.5)
            self.run(moveAction)
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, move])))
    }

    // MARK: - 巡逻边界设置

    func setPatrolBounds(minX: CGFloat, maxX: CGFloat) {
        patrolMinX = minX
        patrolMaxX = maxX
    }

    // MARK: - 受伤/死亡

    func takeDamage(_ amount: Int = 1) {
        health -= amount
        if health <= 0 {
            die()
        } else {
            let flash = SKAction.sequence([
                SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05),
                SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 0.05)
            ])
            run(flash)
        }
    }

    func die() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.3)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([fadeOut, scaleDown, remove]))
    }

    func getScoreValue() -> Int {
        return scoreValue
    }
}
