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

    // PNG 文件名映射
    private static let typeToImage: [String: String] = [
        "dinosaur": "02_enemy_dinosaur",
        "raptor": "06_boss_raptor",
        "snail": "03_enemy_snail",
        "bee": "04_enemy_bee",
        "piranha": "05_enemy_piranha",
        "frog": "07_boss_frog",
        "lizard": "02_enemy_dinosaur",
        "snake": "02_enemy_dinosaur",
        "bat": "29_enemy_bat",
        "volcanic_bat": "29_enemy_bat",
        "skeleton": "31_enemy_skeleton",
        "fire_skeleton": "31_enemy_skeleton",
        "scorpion": "30_enemy_scorpion",
        "seagull": "04_enemy_bee",
        "fire_lizard": "08_boss_lava_dragon",
        "fire_beetle": "28_enemy_skull_fire",
        "magma_worm": "28_enemy_skull_fire",
        "magma_sprite": "28_enemy_skull_fire",
        "magma_ghost": "28_enemy_skull_fire",
        "magma_golem": "28_enemy_skull_fire",
        "storm_vulture": "29_enemy_bat",
        "lightning_lizard": "02_enemy_dinosaur",
        "guardian_statue": "09_boss_dark_dragon",
        "curse_ghost": "28_enemy_skull_fire",
        "ancient_beetle": "28_enemy_skull_fire",
        "sky_knight": "09_boss_dark_dragon",
        "guardian_angel": "07_boss_frog",
        "thunder_orb": "32_projectile_fireball",
        "worm": "28_enemy_skull_fire",
        "lava_dragon": "08_boss_lava_dragon",
        "dark_dragon": "09_boss_dark_dragon"
    ]

    // 精灵尺寸
    private var spriteSize: CGSize = CGSize(width: 50, height: 50)

    // MARK: - 初始化

    init(type: String) {
        self.enemyType = type
        super.init()
        configureByType()
        setupAppearance()
        startPatrolling()
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
        let imageName = Enemy.typeToImage[enemyType] ?? "02_enemy_dinosaur"
        print("🔴 Enemy[\(enemyType)]: loading '\(imageName)'")

        // 尝试加载纹理
        let texture = SKTexture(imageNamed: imageName)
        print("   texture size: \(texture.size())")

        if texture.size().width == 0 {
            print("❌ Enemy[\(enemyType)]: texture '\(imageName)' FAILED to load")
            sprite = SKSpriteNode(color: .red, size: spriteSize)
        } else {
            // 用纹理实际尺寸或指定尺寸
            let displaySize = CGSize(width: 50, height: 50)
            sprite = SKSpriteNode(texture: texture, size: displaySize)
            print("✅ Enemy[\(enemyType)]: loaded texture '\(imageName)'")
        }

        sprite.position = .zero
        addChild(sprite)

        physicsBody = SKPhysicsBody(rectangleOf: spriteSize)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategories.enemy
        physicsBody?.contactTestBitMask = PhysicsCategories.player
        physicsBody?.collisionBitMask = PhysicsCategories.ground
        physicsBody?.allowsRotation = false

        let flyingTypes = ["bat", "volcanic_bat", "storm_vulture", "sky_knight", "guardian_angel", "thunder_orb"]
        physicsBody?.affectedByGravity = !flyingTypes.contains(enemyType)
    }

    private func startPatrolling() {
        let wait = SKAction.wait(forDuration: TimeInterval.random(in: 1.5...3.0))
        let move = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.direction *= -1
            let moveAction = SKAction.moveBy(x: self.direction * self.moveSpeed * 0.5, y: 0, duration: 0.5)
            self.run(moveAction)
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, move])))
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