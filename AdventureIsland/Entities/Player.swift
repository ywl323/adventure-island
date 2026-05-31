import SpriteKit
import AVFoundation

class Player: SKNode {

    // MARK: - 属性
    private var moveSpeed: CGFloat = Constants.playerSpeed
    private var isGrounded: Bool = false
    private var hasEverFallen: Bool = false  // 玩家是否曾经下坠过（用于判断能否跳跃）
    private var isAttacking: Bool = false
    private var health: Int = 3
    private var canJump: Bool = true         // 跳跃冷却，防止连续触发
    private var facingDirection: CGFloat = 1 // 1=右, -1=左，独立于xScale避免动画干扰


    // 精灵节点
    private var sprite: SKSpriteNode!

    // 物理体尺寸（用于碰撞）
    private let physicsRadius: CGFloat = Constants.playerPhysicsRadius

    // MARK: - 初始化

    override init() {
        super.init()
        // 初始设为 true：玩家出生点在地面上方，等待物理引擎检测到地面后再更新状态
        isGrounded = true
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
        physicsBody?.contactTestBitMask = PhysicsCategories.enemy | PhysicsCategories.ground | PhysicsCategories.item | PhysicsCategories.goal
        physicsBody?.collisionBitMask = PhysicsCategories.ground
        physicsBody?.mass = 1.0
        physicsBody?.friction = 0.5
    }

    private func setupPlayer() {
        name = "player"

        // 使用纹理缓存
        let texture = TextureCache.shared.texture(for: "01_player_master_higgins")
        if texture.size().width == 0 {
            sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 40, height: 48))
        } else {
            sprite = SKSpriteNode(texture: texture, size: CGSize(width: 50, height: 60))
        }
        sprite.setScale(Constants.playerSpriteScale)
        sprite.zPosition = 1
        sprite.position = .zero
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        addChild(sprite)
    }

    // MARK: - 移动逻辑

    func moveLeft() {
        let dy = physicsBody?.velocity.dy ?? 0
        physicsBody?.velocity = CGVector(dx: -moveSpeed, dy: dy)
        xScale = -abs(xScale)
        facingDirection = -1
    }

    func moveRight() {
        let dy = physicsBody?.velocity.dy ?? 0
        physicsBody?.velocity = CGVector(dx: moveSpeed, dy: dy)
        xScale = abs(xScale)
        facingDirection = 1
    }

    func stop() {
        let dy = physicsBody?.velocity.dy ?? 0
        physicsBody?.velocity = CGVector(dx: 0, dy: dy)
    }

    // MARK: - 跳跃物理

    func jump() {
        guard canJump else {
            print("⏳ jump() denied: cooldown")
            return
        }
        guard isGrounded else {
            print("⏳ jump() denied: not grounded (isGrounded=false)")
            return
        }
        print("✅ jump() executed! isGrounded=\(isGrounded)")
        physicsBody?.velocity = CGVector(dx: physicsBody?.velocity.dx ?? 0, dy: Constants.jumpForce)
        AudioManager.shared.playSE("se_jump")
        canJump = false
        // 离开地面时重置跳跃冷却，这样下次落地才能再跳
        isGrounded = false
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.jumpCooldown) { [weak self] in
            self?.canJump = true
        }
    }

    // MARK: - 攻击动作（石斧投射物）

    func attack() {
        guard !isAttacking else { return }
        isAttacking = true

        // 生成石斧投射物
        let axeNode: SKSpriteNode
        if UIImage(named: "24_projectile_stone_axe") != nil {
            axeNode = SKSpriteNode(imageNamed: "24_projectile_stone_axe")
            axeNode.size = CGSize(width: 30, height: 30)
        } else {
            // Fallback：使用简单的斧形 ShapeNode
            let axeShape = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 8))
            path.addLine(to: CGPoint(x: -10, y: -4))
            path.addLine(to: CGPoint(x: 0, y: -2))
            path.addLine(to: CGPoint(x: 10, y: -4))
            path.closeSubpath()
            axeShape.path = path
            axeShape.fillColor = SKColor(red: 0.5, green: 0.45, blue: 0.4, alpha: 1.0)
            axeShape.strokeColor = .clear
            axeNode = SKSpriteNode(color: .clear, size: CGSize(width: 24, height: 18))
            axeNode.addChild(axeShape)
        }
        let axe = axeNode
        axe.name = "axe"
        axe.zPosition = 10
        axe.position = CGPoint(x: 0, y: 20)

        // 根据角色朝向决定飞行方向（使用独立的facingDirection，避免被xScale动画干扰）
        let direction: CGFloat = facingDirection
        axe.xScale = abs(axe.xScale) * direction  // 确保朝向正确

        // 投出轨迹（抛物线）
        let duration: TimeInterval = Constants.attackDuration
        let dx: CGFloat = direction * Constants.attackMoveDistance
        let dy: CGFloat = Constants.attackMoveHeight  // 轻微上抛
        let fly = SKAction.sequence([
            SKAction.moveBy(x: dx, y: dy, duration: duration),
            SKAction.removeFromParent()
        ])
        let spin = SKAction.rotate(byAngle: direction * .pi * 4, duration: duration)
        axe.run(SKAction.group([fly, spin]))

        addChild(axe)

        // 攻击音效
        AudioManager.shared.playSE("se_attack")

        let finish = SKAction.run { [weak self] in
            self?.isAttacking = false
        }
        run(SKAction.sequence([SKAction.wait(forDuration: Constants.attackFinishDelay), finish]))
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
        isGrounded = true  // 复活后设为 true，物理引擎接触地面后会更新
        hasEverFallen = false
        isAttacking = false
        canJump = true           // 复活后立即可以跳跃
        health = Constants.maxHealth  // 满血复活
        position = CGPoint(x: Constants.playerStartX, y: Constants.playerStartY)
        physicsBody?.velocity = .zero
        alpha = 1.0
        facingDirection = 1      // 面向右侧
        xScale = abs(xScale)     // 重置朝向
    }

    // MARK: - 每帧更新

    func update() {
        let vy = physicsBody?.velocity.dy ?? 0

        // 只在明显下坠时标记为离开地面，避免每帧误判
        // isGrounded 由 didContact/didEndContact 控制，这里只做辅助判断
        if vy < -100 {
            hasEverFallen = true
        }
    }

    // MARK: - 碰撞回调

    func didContact(with category: UInt32) {
        if category == PhysicsCategories.ground {
            isGrounded = true
        }
    }

    func didEndContact(with category: UInt32) {
        if category == PhysicsCategories.ground {
            isGrounded = false
        }
    }

    // MARK: - 状态查询

    func isAlive() -> Bool {
        return health > 0
    }

    func getHealth() -> Int {
        return health
    }

    func resetHealth() {
        health = 3
    }

    func getFacingDirection() -> CGFloat {
        return facingDirection
    }
}