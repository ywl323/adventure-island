import SpriteKit

class Enemy: SKNode {

    // MARK: - 属性
    private var enemyType: String = "basic"
    private var health: Int = 1
    private var moveSpeed: CGFloat = 100
    private var damage: Int = 1
    private var scoreValue: Int = 100
    private var body: SKShapeNode!

    // 移动方向
    private var direction: CGFloat = 1

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
            health = 1
            moveSpeed = 80
            damage = 1
            scoreValue = 100
        case "bee", "lizard", "snake", "skeleton":
            health = 1
            moveSpeed = 120
            damage = 1
            scoreValue = 150
        case "bat", "scorpion":
            health = 2
            moveSpeed = 100
            damage = 1
            scoreValue = 200
        case "fire_lizard", "fire_skeleton", "volcanic_bat", "magma_sprite":
            health = 2
            moveSpeed = 140
            damage = 2
            scoreValue = 250
        case "storm_vulture", "lightning_lizard":
            health = 2
            moveSpeed = 160
            damage = 2
            scoreValue = 300
        case "guardian_statue", "curse_ghost":
            health = 3
            moveSpeed = 60
            damage = 2
            scoreValue = 400
        case "sky_knight", "guardian_angel":
            health = 3
            moveSpeed = 180
            damage = 2
            scoreValue = 350
        case "worm", "fire_beetle", "magma_ghost", "magma_golem":
            health = 3
            moveSpeed = 100
            damage = 2
            scoreValue = 300
        case "thunder_orb":
            health = 2
            moveSpeed = 200
            damage = 2
            scoreValue = 350
        case "piranha":
            health = 1
            moveSpeed = 150
            damage = 1
            scoreValue = 150
        default:
            health = 1
            moveSpeed = 100
            damage = 1
            scoreValue = 100
        }
    }

    private func setupAppearance() {
        let size: CGSize
        let color: SKColor

        switch enemyType {
        case "dinosaur", "raptor":
            size = CGSize(width: 60, height: 50)
            color = SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
        case "snail":
            size = CGSize(width: 40, height: 30)
            color = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0)
        case "seagull":
            size = CGSize(width: 50, height: 35)
            color = SKColor(white: 0.9, alpha: 1.0)
        case "bee":
            size = CGSize(width: 30, height: 25)
            color = SKColor(red: 0.9, green: 0.8, blue: 0.2, alpha: 1.0)
        case "bat", "volcanic_bat":
            size = CGSize(width: 45, height: 30)
            color = SKColor(red: 0.3, green: 0.2, blue: 0.4, alpha: 1.0)
        case "skeleton", "fire_skeleton":
            size = CGSize(width: 45, height: 55)
            color = SKColor(white: 0.85, alpha: 1.0)
        case "snake", "lizard", "fire_lizard":
            size = CGSize(width: 55, height: 30)
            color = SKColor(red: 0.4, green: 0.6, blue: 0.3, alpha: 1.0)
        case "scorpion":
            size = CGSize(width: 50, height: 35)
            color = SKColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0)
        case "worm", "magma_worm", "magma_sprite", "magma_golem":
            size = CGSize(width: 50, height: 50)
            color = SKColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1.0)
        case "fire_beetle":
            size = CGSize(width: 40, height: 30)
            color = SKColor(red: 0.7, green: 0.2, blue: 0.1, alpha: 1.0)
        case "magma_ghost":
            size = CGSize(width: 45, height: 55)
            color = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.7)
        case "piranha":
            size = CGSize(width: 40, height: 35)
            color = SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 1.0)
        case "storm_vulture", "lightning_lizard":
            size = CGSize(width: 55, height: 40)
            color = SKColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
        case "guardian_statue":
            size = CGSize(width: 60, height: 70)
            color = SKColor(gray: 0.6, alpha: 1.0)
        case "curse_ghost":
            size = CGSize(width: 45, height: 55)
            color = SKColor(red: 0.3, green: 0.0, blue: 0.4, alpha: 0.8)
        case "ancient_beetle":
            size = CGSize(width: 40, height: 30)
            color = SKColor(red: 0.4, green: 0.35, blue: 0.3, alpha: 1.0)
        case "sky_knight":
            size = CGSize(width: 50, height: 50)
            color = SKColor(red: 0.7, green: 0.7, blue: 0.9, alpha: 1.0)
        case "thunder_orb":
            size = CGSize(width: 40, height: 40)
            color = SKColor(red: 0.9, green: 0.9, blue: 0.3, alpha: 1.0)
        case "guardian_angel":
            size = CGSize(width: 65, height: 65)
            color = SKColor(red: 0.9, green: 0.85, blue: 0.7, alpha: 1.0)
        default:
            size = CGSize(width: 50, height: 45)
            color = SKColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0)
        }

        body = SKShapeNode(rectOf: size, cornerRadius: 8)
        body.fillColor = color
        body.strokeColor = .white
        body.lineWidth = 2
        addChild(body)

        // 添加眼睛
        let eye1 = SKShapeNode(circleOfRadius: 5)
        eye1.fillColor = .red
        eye1.strokeColor = .white
        eye1.position = CGPoint(x: -12, y: size.height / 4)
        addChild(eye1)

        let eye2 = SKShapeNode(circleOfRadius: 5)
        eye2.fillColor = .red
        eye2.strokeColor = .white
        eye2.position = CGPoint(x: 12, y: size.height / 4)
        addChild(eye2)

        // 设置物理体
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCategories.enemy
        physicsBody?.contactTestBitMask = PhysicsCategories.player
        physicsBody?.collisionBitMask = PhysicsCategories.ground
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = (enemyType != "bat" && !enemyType.contains("bat") && !enemyType.contains("vulture"))
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
            // 受伤闪烁
            let flash = SKAction.sequence([
                SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05),
                SKAction.colorize(withColorFilter: nil, duration: 0.05)
            ])
            run(flash)
        }
    }

    func die() {
        // 死亡动画
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.3)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([fadeOut, scaleDown, remove]))
    }

    func getScoreValue() -> Int {
        return scoreValue
    }
}