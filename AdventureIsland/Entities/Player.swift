import SpriteKit
import AVFoundation

class Player: SKNode {

    // MARK: - 属性
    private var moveSpeed: CGFloat = Constants.playerSpeed
    var isGrounded: Bool = false  // 可被 GameScene 初始化
    private var hasEverFallen: Bool = false  // 玩家是否曾经下坠过（用于判断能否跳跃）
    private var isAttacking: Bool = false
    private var health: Int = 3
    private var canJump: Bool = true         // 跳跃冷却，防止连续触发
    private var isJumpLocked: Bool = false    // 跳跃序列锁：跳跃进行中锁定，落地后自动解锁
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
        guard canJump && !isJumpLocked else {
            print("⏳ jump() denied: canJump=\(canJump), isJumpLocked=\(isJumpLocked)")
            return
        }
        guard isGrounded else {
            print("⏳ jump() denied: not grounded (isGrounded=false)")
            return
        }
        print("✅ jump() executed! isGrounded=\(isGrounded)")
        canJump = false
        isJumpLocked = true  // 锁住跳跃序列，落地前不能再跳
        physicsBody?.velocity = CGVector(dx: physicsBody?.velocity.dx ?? 0, dy: Constants.jumpForce)
        AudioManager.shared.playSE("se_jump")
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.jumpCooldown) { [weak self] in
            self?.canJump = true
        }
    }

    // MARK: - 攻击动作（石斧投射物）

    func attack() {
        guard !isAttacking else { return }
        isAttacking = true

        // 生成石斧投射物（分叉处理：图片 vs fallback ShapeNode）
        let axeNode: SKNode
        if UIImage(named: "24_projectile_stone_axe") != nil {
            let axeSprite = SKSpriteNode(imageNamed: "24_projectile_stone_axe")
            axeSprite.size = CGSize(width: 40, height: 40)
            axeNode = axeSprite
        } else {
            // Fallback：使用更明显的斧形 ShapeNode（更像真实的斧子）
            let axeShape = SKShapeNode()
            // 斧柄
            let handle = SKShapeNode(rect: CGRect(x: -3, y: -16, width: 6, height: 20))
            handle.fillColor = SKColor(red: 0.55, green: 0.35, blue: 0.2, alpha: 1.0)
            handle.strokeColor = .clear
            // 斧刃（半月形）
            let bladePath = CGMutablePath()
            bladePath.move(to: CGPoint(x: -14, y: 2))
            bladePath.addQuadCurve(to: CGPoint(x: 14, y: 2), control: CGPoint(x: 0, y: 12))
            bladePath.addLine(to: CGPoint(x: 14, y: -2))
            bladePath.addQuadCurve(to: CGPoint(x: -14, y: -2), control: CGPoint(x: 0, y: 6))
            bladePath.closeSubpath()
            let blade = SKShapeNode(path: bladePath)
            blade.fillColor = SKColor(red: 0.55, green: 0.55, blue: 0.6, alpha: 1.0)
            blade.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
            blade.lineWidth = 1
            // 组装斧子
            axeNode = SKNode()
            axeNode.addChild(handle)
            axeNode.addChild(blade)
        }
        let axe = axeNode
        axe.name = "axe"
        axe.zPosition = 10
        axe.setScale(0.5)  // 斧子缩小到合理尺寸
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
        let spin = SKAction.rotate(byAngle: direction * .pi * 2, duration: duration)
        // 斧子不旋转，改用轻微上下晃动模拟重量感
        let wobble = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 0.1),
            SKAction.moveBy(x: 0, y: -3, duration: 0.1)
        ])
        let wobbleRepeat = SKAction.repeatForever(wobble)
        axe.run(SKAction.group([fly, spin, wobbleRepeat]))

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
            isJumpLocked = false  // 落地后解锁跳跃序列，允许下次跳跃
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