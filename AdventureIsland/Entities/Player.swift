import SpriteKit

class Player: SKNode {

    // MARK: - 属性
    private var moveSpeed: CGFloat = Constants.playerSpeed
    private var isGrounded: Bool = false
    private var isAttacking: Bool = false
    private var health: Int = 3

    // 精灵节点
    private var sprite: SKSpriteNode!

    // 物理体尺寸（用于碰撞）
    private let physicsRadius: CGFloat = 20

    // MARK: - 初始化

    override init() {
        super.init()
        setupPhysics()
        setupPlayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: physicsRadius)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategories.player
        physicsBody?.contactTestBitMask = PhysicsCategories.enemy | PhysicsCategories.ground | PhysicsCategories.item
        physicsBody?.collisionBitMask = PhysicsCategories.ground
        physicsBody?.mass = 1.0
        physicsBody?.friction = 0.5
    }

    private func setupPlayer() {
        name = "player"

        // 尝试从 asset catalog 加载 PNG
        let texture = SKTexture(imageNamed: "01_player_master_higgins")

        // 如果纹理加载成功（尺寸有效），使用它；否则用彩色方块代替
        if texture.size().width > 0 && texture.size().height > 0 {
            // 根据纹理实际尺寸的1/10来设置显示大小（因为原图是像素级的）
            let texSize = texture.size()
            let displaySize = CGSize(width: texSize.width, height: texSize.height)
            sprite = SKSpriteNode(texture: texture, size: displaySize)
            print("✅ Player texture loaded: \(texSize)")
        } else {
            // Fallback：用彩色方块代替，方便调试
            print("⚠️ Player texture NOT found, using placeholder")
            sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 32, height: 40))
        }

        sprite.position = .zero
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0) // 底部中心为锚点
        addChild(sprite)
    }

    // MARK: - 移动逻辑

    func moveLeft() {
        physicsBody?.velocity.dx = -moveSpeed
        xScale = -abs(xScale)
    }

    func moveRight() {
        physicsBody?.velocity.dx = moveSpeed
        xScale = abs(xScale)
    }

    func stop() {
        physicsBody?.velocity.dx = 0
    }

    // MARK: - 跳跃物理

    func jump() {
        guard isGrounded else { return }
        physicsBody?.velocity = CGVector(dx: physicsBody?.velocity.dx ?? 0, dy: Constants.jumpForce)
        isGrounded = false
    }

    // MARK: - 攻击动作

    func attack() {
        guard !isAttacking else { return }
        isAttacking = true

        let originalColor = sprite.color
        let originalColorBlend = sprite.colorBlendFactor
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.sprite.color = .red
                self?.sprite.colorBlendFactor = 0.5
            },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { [weak self] in
                self?.sprite.color = originalColor
                self?.sprite.colorBlendFactor = originalColorBlend
            },
            SKAction.wait(forDuration: 0.2)
        ])
        sprite.run(flash)

        let finish = SKAction.run { [weak self] in
            self?.isAttacking = false
        }
        run(SKAction.sequence([SKAction.wait(forDuration: 0.3), finish]))
    }

    // MARK: - 受伤闪烁

    func takeDamage() {
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.fadeIn(withDuration: 0.1)
        ])
        sprite.run(blink)
    }

    // MARK: - 死亡逻辑

    func die() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let reset = SKAction.run { [weak self] in
            self?.reset()
        }
        run(SKAction.sequence([fadeOut, reset]))
    }

    private func reset() {
        isGrounded = false
        isAttacking = false
        position = CGPoint(x: 200, y: 200)
        physicsBody?.velocity = .zero
        alpha = 1.0
    }

    // MARK: - 更新逻辑

    func update() {
        // 保持玩家在地面以上（简单碰撞处理）
        if position.y < 100 && isGrounded {
            position.y = 100
        }
    }

    // MARK: - 碰撞回调

    func didContact(with category: UInt32) {
        if category == PhysicsCategories.ground {
            isGrounded = true
        }
    }
}