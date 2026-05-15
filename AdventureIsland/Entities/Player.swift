import SpriteKit
import AVFoundation

class Player: SKNode {

    // MARK: - 属性
    private var moveSpeed: CGFloat = Constants.playerSpeed
    private var isGrounded: Bool = false
    private var isAttacking: Bool = false
    private var health: Int = 3
    private var lastVelocityY: CGFloat = 0

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

        // 尝试从 asset catalog 加载纹理
        sprite = SKSpriteNode(imageNamed: "01_player_master_higgins")

        if sprite.texture == nil || sprite.texture!.size().width == 0 {
            print("⚠️ Player: '01_player_master_higgins' NOT found in asset catalog")

            let possibleNames = [
                "01_player_master_higgins",
                "player",
                "adventure_island_logo1"
            ]

            for name in possibleNames {
                sprite = SKSpriteNode(imageNamed: name)
                if sprite.texture != nil && sprite.texture!.size().width > 0 {
                    print("✅ Player: found texture '\(name)' (\(sprite.texture!.size()))")
                    break
                }
            }

            if sprite.texture == nil || sprite.texture!.size().width == 0 {
                print("❌ Player: No valid texture found — USAGE ERROR: missing '01_player_master_higgins' in Assets.xcassets")
                sprite = SKSpriteNode(color: .cyan, size: CGSize(width: 40, height: 48))
            }
        } else {
            print("✅ Player: loaded '01_player_master_higgins' texture size: \(sprite.texture!.size())")
        }

        sprite.setScale(0.15)
        sprite.position = .zero
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
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
        AudioManager.shared.playSE("se_jump")
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

        AudioManager.shared.playSE("se_attack")
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

    // MARK: - 每帧更新

    func update() {
        // 用速度方向变化判断落地：刚从下落（vy <= -50）转为非下落，说明着地
        let vy = physicsBody?.velocity.dy ?? 0
        if vy > -50 && lastVelocityY <= -50 {
            isGrounded = true
        } else if vy < -50 {
            isGrounded = false
        }
        lastVelocityY = vy

        // 防止掉出屏幕底部
        if position.y < 100 && isGrounded {
            position.y = 100
        }
    }

    // MARK: - 碰撞回调

    func didContact(with category: UInt32) {
        if category == PhysicsCategories.ground {
            let vy = physicsBody?.velocity.dy ?? 0
            if vy <= 0 {
                isGrounded = true
            }
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
}