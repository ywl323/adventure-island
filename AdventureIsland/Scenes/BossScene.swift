import SpriteKit

class BossScene: SKScene {

    // MARK: - 节点属性
    private var player: Player!
    private var boss: BossNode!
    private var cameraNode: SKCameraNode!

    // MARK: - HUD
    private var scoreLabel: SKLabelNode!
    private var healthLabel: SKLabelNode!
    private var bossHealthLabel: SKLabelNode!
    private var timeLabel: SKLabelNode!
    private var levelNameLabel: SKLabelNode!

    // MARK: - 控制区域
    private var leftButton: SKShapeNode!
    private var rightButton: SKShapeNode!
    private var jumpButton: SKShapeNode!
    private var attackButton: SKShapeNode!

    // MARK: - 游戏状态
    private var score: Int = 0
    private var health: Int = 3
    private var gameTime: Int = 120
    private var isGameOver: Bool = false
    private var isVictory: Bool = false

    // MARK: - 关卡数据
    private var levelData: LevelData

    // 触摸状态
    private var isLeftPressed: Bool = false
    private var isRightPressed: Bool = false
    private var isJumpPressed: Bool = false
    private var isAttackPressed: Bool = false

    // MARK: - 背景
    private var backgroundLayer: SKNode!

    // MARK: - 世界边界
    private var worldBounds: CGRect!

    init(size: CGSize, levelData: LevelData) {
        self.levelData = levelData
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        gameTime = levelData.timeLimit
        setupPhysics()
        setupCamera()
        setupBackground()
        setupPlayer()
        setupBoss()
        setupHUD()
        setupControlArea()
        startGameTimer()
    }

    // MARK: - 设置

    private func setupPhysics() {
        worldBounds = CGRect(x: 0, y: 0, width: 3000, height: size.height)
        physicsWorld.gravity = CGVector(dx: 0, dy: -Constants.gravity)
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
    }

    private func setupBackground() {
        backgroundLayer = SKNode()
        addChild(backgroundLayer)

        // 根据地形设置背景
        let bgColor: SKColor
        switch levelData.specialFeature {
        case "boss_raptor":
            bgColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1.0) // 草地绿
        case "boss_frog":
            bgColor = SKColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0) // 沼泽绿
        case "boss_lava":
            bgColor = SKColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1.0) // 火山红
        case "boss_dark":
            bgColor = SKColor(red: 0.15, green: 0.05, blue: 0.2, alpha: 1.0) // 深紫色星空
        default:
            bgColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
        }

        let background = SKSpriteNode(color: bgColor, size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundLayer.addChild(background)

        // 添加地面
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 3000, height: 50))
        ground.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
        ground.strokeColor = .clear
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: 3000, y: 0))
        ground.physicsBody?.categoryBitMask = PhysicsCategories.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategories.player
        backgroundLayer.addChild(ground)

        // BOSS区域装饰 - 根据BOSS类型添加掩体
        if levelData.specialFeature == "boss_dark" {
            // 最终BOSS：4根石柱
            for i in 0..<4 {
                let pillar = SKShapeNode(rect: CGRect(x: 600 + CGFloat(i) * 500, y: 50, width: 90, height: 150))
                pillar.fillColor = SKColor(white: 0.5, alpha: 1.0)
                pillar.strokeColor = .clear
                pillar.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: 90, height: 150))
                pillar.physicsBody?.categoryBitMask = PhysicsCategories.ground
                backgroundLayer.addChild(pillar)
            }
        } else {
            // 普通BOSS：中央掩体
            let centerPlatform = SKShapeNode(rect: CGRect(x: 1350, y: 50, width: 150, height: 80))
            centerPlatform.fillColor = SKColor(white: 0.4, alpha: 1.0)
            centerPlatform.strokeColor = .clear
            centerPlatform.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: 150, height: 80))
            centerPlatform.physicsBody?.categoryBitMask = PhysicsCategories.ground
            backgroundLayer.addChild(centerPlatform)
        }
    }

    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: 200, y: 200)
        addChild(player)
    }

    private func setupBoss() {
        boss = BossNode(type: levelData.specialFeature)
        boss.position = CGPoint(x: 2000, y: 200)
        addChild(boss)
    }

    private func setupHUD() {
        // 关卡名称
        levelNameLabel = SKLabelNode(text: "BOSS: \(levelData.name)")
        levelNameLabel.fontName = "Helvetica-Bold"
        levelNameLabel.fontSize = 28
        levelNameLabel.fontColor = .red
        levelNameLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        levelNameLabel.horizontalAlignmentMode = .center
        cameraNode.addChild(levelNameLabel)

        // 分数
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 80, y: size.height - 80)
        scoreLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(scoreLabel)

        // 生命
        healthLabel = SKLabelNode(text: "Health: 3")
        healthLabel.fontName = "Helvetica-Bold"
        healthLabel.fontSize = 24
        healthLabel.fontColor = .white
        healthLabel.position = CGPoint(x: 80, y: size.height - 110)
        healthLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(healthLabel)

        // BOSS生命
        bossHealthLabel = SKLabelNode(text: "BOSS: ♥♥♥")
        bossHealthLabel.fontName = "Helvetica-Bold"
        bossHealthLabel.fontSize = 24
        bossHealthLabel.fontColor = .red
        bossHealthLabel.position = CGPoint(x: size.width - 150, y: size.height - 80)
        bossHealthLabel.horizontalAlignmentMode = .right
        cameraNode.addChild(bossHealthLabel)

        // 时间
        timeLabel = SKLabelNode(text: "Time: \(gameTime)")
        timeLabel.fontName = "Helvetica-Bold"
        timeLabel.fontSize = 24
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: 80, y: size.height - 140)
        timeLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(timeLabel)
    }

    private func setupControlArea() {
        // 左按钮
        leftButton = SKShapeNode(circleOfRadius: 40)
        leftButton.fillColor = SKColor(white: 1.0, alpha: 0.3)
        leftButton.strokeColor = .white
        leftButton.position = CGPoint(x: 80, y: 80)
        leftButton.name = "leftButton"
        cameraNode.addChild(leftButton)

        // 右按钮
        rightButton = SKShapeNode(circleOfRadius: 40)
        rightButton.fillColor = SKColor(white: 1.0, alpha: 0.3)
        rightButton.strokeColor = .white
        rightButton.position = CGPoint(x: 180, y: 80)
        rightButton.name = "rightButton"
        cameraNode.addChild(rightButton)

        // 跳跃按钮
        jumpButton = SKShapeNode(circleOfRadius: 40)
        jumpButton.fillColor = SKColor(white: 1.0, alpha: 0.3)
        jumpButton.strokeColor = .white
        jumpButton.position = CGPoint(x: size.width - 180, y: 80)
        jumpButton.name = "jumpButton"
        cameraNode.addChild(jumpButton)

        // 攻击按钮
        attackButton = SKShapeNode(circleOfRadius: 40)
        attackButton.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.5)
        attackButton.strokeColor = .red
        attackButton.position = CGPoint(x: size.width - 80, y: 80)
        attackButton.name = "attackButton"
        cameraNode.addChild(attackButton)
    }

    private func startGameTimer() {
        let wait = SKAction.wait(forDuration: 1.0)
        let update = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.gameTime -= 1
            self.timeLabel.text = "Time: \(self.gameTime)"
            if self.gameTime <= 0 {
                self.gameOver()
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, update])))
    }

    // MARK: - 触摸处理

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isGameOver && !isVictory else { return }
        let location = touch.location(in: cameraNode)
        let node = self.cameraNode.atPoint(location)

        switch node.name {
        case "leftButton":
            isLeftPressed = true
        case "rightButton":
            isRightPressed = true
        case "jumpButton":
            isJumpPressed = true
        case "attackButton":
            isAttackPressed = true
        default:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isLeftPressed = false
        isRightPressed = false
        isJumpPressed = false
        isAttackPressed = false
    }

    // MARK: - 更新逻辑

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver && !isVictory else { return }

        // 玩家移动
        if isLeftPressed {
            player.moveLeft()
        } else if isRightPressed {
            player.moveRight()
        } else {
            player.stop()
        }

        // 跳跃
        if isJumpPressed {
            player.jump()
            isJumpPressed = false
        }

        // 攻击
        if isAttackPressed {
            player.attack()
            checkAttackHit()
            isAttackPressed = false
        }

        // BOSS AI
        boss.update(playerPosition: player.position)

        // 摄像机跟随
        cameraNode.position.x = (player.position.x + boss.position.x) / 2

        // 更新玩家状态
        player.update()
    }

    // MARK: - 战斗逻辑

    private func checkAttackHit() {
        let attackRange = CGRect(x: player.position.x - 50, y: player.position.y - 30, width: 100, height: 60)
        if attackRange.intersects(boss.frame) {
            boss.takeDamage()
            addScore(100)
            updateBossHealthDisplay()

            if boss.isDefeated {
                victory()
            }
        }
    }

    private func updateBossHealthDisplay() {
        let hearts = boss.hp
        var heartStr = ""
        for _ in 0..<boss.maxHP {
            heartStr += hearts > 0 ? "♥" : "♡"
        }
        bossHealthLabel.text = "BOSS: \(heartStr)"
    }

    // MARK: - 游戏逻辑

    func addScore(_ points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
    }

    func takeDamage() {
        health -= 1
        healthLabel.text = "Health: \(health)"
        if health <= 0 {
            gameOver()
        }
    }

    private func gameOver() {
        isGameOver = true
        let gameOverScene = GameOverScene(size: size, score: score)
        gameOverScene.scaleMode = scaleMode
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: transition)
    }

    private func victory() {
        isVictory = true
        let levelCompleteScene = LevelCompleteScene(
            size: size,
            levelNumber: levelData.levelNumber,
            levelName: levelData.name,
            score: score,
            timeRemaining: gameTime
        )
        levelCompleteScene.scaleMode = scaleMode
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(levelCompleteScene, transition: transition)
    }

    // MARK: - 碰撞检测

    func didCollideWithEnemy() {
        takeDamage()
    }
}

// MARK: - BOSS节点
class BossNode: SKNode {
    var hp: Int = 3
    var maxHP: Int = 3
    var isDefeated: Bool = false

    private var bossType: String
    private var body: SKShapeNode!

    init(type: String) {
        self.bossType = type
        super.init()

        // 根据BOSS类型设置HP
        switch type {
        case "boss_raptor":
            maxHP = 3
            hp = 3
        case "boss_frog":
            maxHP = 4
            hp = 4
        case "boss_lava":
            maxHP = 5
            hp = 5
        case "boss_dark":
            maxHP = 6
            hp = 6
        default:
            maxHP = 3
            hp = 3
        }

        setupBossAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBossAppearance() {
        let size: CGSize
        let color: SKColor

        switch bossType {
        case "boss_raptor":
            size = CGSize(width: 120, height: 100)
            color = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0) // 红色恐龙
        case "boss_frog":
            size = CGSize(width: 140, height: 100)
            color = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0) // 绿色青蛙
        case "boss_lava":
            size = CGSize(width: 160, height: 120)
            color = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0) // 熔岩龙
        case "boss_dark":
            size = CGSize(width: 200, height: 150)
            color = SKColor(red: 0.2, green: 0.0, blue: 0.3, alpha: 1.0) // 黑暗龙神
        default:
            size = CGSize(width: 100, height: 80)
            color = SKColor.gray
        }

        body = SKShapeNode(rectOf: size, cornerRadius: 10)
        body.fillColor = color
        body.strokeColor = .white
        body.lineWidth = 3
        addChild(body)

        // 添加眼睛
        let eye1 = SKShapeNode(circleOfRadius: 10)
        eye1.fillColor = .red
        eye1.strokeColor = .white
        eye1.position = CGPoint(x: -25, y: 20)
        addChild(eye1)

        let eye2 = SKShapeNode(circleOfRadius: 10)
        eye2.fillColor = .red
        eye2.strokeColor = .white
        eye2.position = CGPoint(x: 25, y: 20)
        addChild(eye2)
    }

    func takeDamage() {
        hp -= 1
        if hp <= 0 {
            isDefeated = true
        }

        // 受伤闪烁效果
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 0.1)
        ])
        run(flash)
    }

    func update(playerPosition: CGPoint) {
        // 简单的BOSS AI - 向玩家移动
        let direction = playerPosition.x > position.x ? 1 : -1
        position.x += CGFloat(direction) * 1.5
    }
}