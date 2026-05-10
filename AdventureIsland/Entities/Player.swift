import SpriteKit

class Player: SKSpriteNode {

    // MARK: - 属性
    private var moveSpeed: CGFloat = Constants.playerSpeed
    private var isGrounded: Bool = false
    private var isAttacking: Bool = false
    private var health: Int = 3

    // 动画状态
    private var currentAnimation: SKAction?

    // MARK: - 初始化

    init() {
        let texture = SKTexture(imageNamed: "player")
        super.init(texture: texture, color: .clear, size: texture.size())
        setupPhysics()
        setupPlayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        // 使用圆形物理体作为玩家碰撞体
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
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
        // 默认站姿
        runAnimation(.idle)
    }

    // MARK: - 移动逻辑

    func moveLeft() {
        physicsBody?.velocity.dx = -moveSpeed
        xScale = -1
        if isGrounded && !isAttacking {
            runAnimation(.walk)
        }
    }

    func moveRight() {
        physicsBody?.velocity.dx = moveSpeed
        xScale = 1
        if isGrounded && !isAttacking {
            runAnimation(.walk)
        }
    }

    func stop() {
        if isGrounded && !isAttacking {
            physicsBody?.velocity.dx = 0
            runAnimation(.idle)
        }
    }

    // MARK: - 跳跃物理

    func jump() {
        guard isGrounded else { return }
        physicsBody?.velocity = CGVector(dx: physicsBody?.velocity.dx ?? 0, dy: Constants.jumpForce)
        isGrounded = false
        runAnimation(.jump)
    }

    // MARK: - 攻击动作

    func attack() {
        guard !isAttacking else { return }
        isAttacking = true
        runAnimation(.attack)

        // 攻击持续时间后恢复
        let wait = SKAction.wait(forDuration: 0.3)
        let finish = SKAction.run { [weak self] in
            self?.isAttacking = false
            self?.runAnimation(.idle)
        }
        run(SKAction.sequence([wait, finish]))
    }

    // MARK: - 死亡逻辑

    func die() {
        // 死亡动画
        runAnimation(.die)

        // 延迟重置位置或游戏结束
        let wait = SKAction.wait(forDuration: 1.0)
        let reset = SKAction.run { [weak self] in
            self?.reset()
        }
        run(SKAction.sequence([wait, reset]))
    }

    private func reset() {
        isGrounded = false
        isAttacking = false
        position = CGPoint(x: 200, y: 200)
        physicsBody?.velocity = .zero
        runAnimation(.idle)
    }

    // MARK: - 动画播放

    private enum PlayerAnimation {
        case idle
        case walk
        case jump
        case attack
        case die
    }

    private func runAnimation(_ animation: PlayerAnimation) {
        // TODO: 实现具体动画帧
        // 此处为框架占位，后续添加具体资源后实现
    }

    // MARK: - 更新逻辑

    func update() {
        // 检测是否在地面上
        // isGrounded = 检查地面碰撞状态
    }

    // MARK: - 碰撞回调

    func didContact(with category: UInt32) {
        if category == PhysicsCategories.ground {
            isGrounded = true
        }
    }
}
