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

        // 从 asset catalog 加载 PNG（使用完整资源路径）
        let texture = SKTexture(imageNamed: "01_player_master_higgins")
        sprite = SKSpriteNode(texture: texture, size: CGSize(width: 40, height: 50))
        sprite.position = .zero
        addChild(sprite)
    }

    // MARK: - 移动逻辑

    func moveLeft() {
        physicsBody?.velocity.dx = -moveSpeed
        xScale = -1
    }

    func moveRight() {
        physicsBody?.velocity.dx = moveSpeed
        xScale = 1
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
        // 后续可扩展
    }

    // MARK: - 碰撞回调

    func didContact(with category: UInt32) {
        if category == PhysicsCategories.ground {
            isGrounded = true
        }
    }
}
