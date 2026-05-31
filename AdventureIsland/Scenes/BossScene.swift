import SpriteKit

class BossScene: SKScene, SKPhysicsContactDelegate {

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
    private var leftButton: SKNode!
    private var rightButton: SKNode!
    private var jumpButton: SKNode!
    private var attackButton: SKNode!

    // MARK: - 游戏状态
    private var score: Int = 0
    private var health: Int = 3
    private var gameTime: Int = 120
    private var isGameOver: Bool = false
    private var isVictory: Bool = false

    // 受伤/攻击冷却
    private var damageCooldown: Bool = false

    // MARK: - 关卡数据
    private var levelData: LevelData

    // 触摸状态
    private var isLeftPressed: Bool = false
    private var isRightPressed: Bool = false
    private var isJumpPressed: Bool = false
    private var isJumpConsumed: Bool = false  // 防止按住跳跃键一直跳
    private var isAttackPressed: Bool = false
    private var isAttackConsumed: Bool = false  // 防止按住攻击键一直判定

    // 多指触摸跟踪：touch hash → button name，避免 touchesEnded 无法识别释放的是哪个键
    private var activeTouches: [Int: String] = [:]

    // MARK: - 背景
    private var backgroundLayer: SKNode!

    // MARK: - 世界边界
    private var worldBounds: CGRect!

    // MARK: - 暂停
    private var isPausedGame: Bool = false
    private var pauseNode: SKNode!

    init(size: CGSize, levelData: LevelData) {
        self.levelData = levelData
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) { super.didMove(to: view); 
        gameTime = levelData.timeLimit
        setupPhysics()
        setupCamera()
        setupBackground()
        setupPlayer()
        setupBoss()
        setupHUD()
        setupControlArea()
        startGameTimer()
        setupAudio()
    }

    // MARK: - 设置

    private func setupPhysics() {
        worldBounds = CGRect(x: 0, y: 0, width: 3000, height: size.height)
        physicsWorld.gravity = CGVector(dx: 0, dy: -Constants.gravity)
        physicsWorld.contactDelegate = self
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

        let bgColor: SKColor
        if levelData.terrainType == "boss" {
            switch levelData.specialFeature {
            case "boss_raptor":
                bgColor = SKColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1.0)
            case "boss_frog":
                bgColor = SKColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0)
            case "boss_lava":
                bgColor = SKColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1.0)
            case "boss_dark":
                bgColor = SKColor(red: 0.15, green: 0.05, blue: 0.2, alpha: 1.0)
            default:
                bgColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
            }
        } else {
            bgColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
        }

        let background = SKSpriteNode(color: bgColor, size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundLayer.addChild(background)

        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 3000, height: 50))
        ground.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
        ground.strokeColor = .clear
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: 3000, y: 0))
        ground.physicsBody?.categoryBitMask = PhysicsCategories.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategories.player
        backgroundLayer.addChild(ground)

        if levelData.specialFeature == "boss_dark" {
            for i in 0..<4 {
                let pillar = SKShapeNode(rect: CGRect(x: 600 + CGFloat(i) * 500, y: 50, width: 90, height: 150))
                pillar.fillColor = SKColor(white: 0.5, alpha: 1.0)
                pillar.strokeColor = .clear
                pillar.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: 90, height: 150))
                pillar.physicsBody?.categoryBitMask = PhysicsCategories.ground
                backgroundLayer.addChild(pillar)
            }
        } else {
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
        player.position = CGPoint(x: Constants.playerStartX, y: Constants.playerStartY)
        addChild(player)
    }

    private func setupBoss() {
        boss = BossNode(type: levelData.specialFeature)
        boss.position = CGPoint(x: 2000, y: 200)
        addChild(boss)
    }

    private func setupHUD() {
        levelNameLabel = SKLabelNode(text: "BOSS: \(levelData.name)")
        levelNameLabel.fontName = "Helvetica-Bold"
        levelNameLabel.fontSize = 28
        levelNameLabel.fontColor = .red
        levelNameLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        levelNameLabel.horizontalAlignmentMode = .center
        cameraNode.addChild(levelNameLabel)

        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 80, y: size.height - 80)
        scoreLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(scoreLabel)

        healthLabel = SKLabelNode(text: "Health: 3")
        healthLabel.fontName = "Helvetica-Bold"
        healthLabel.fontSize = 24
        healthLabel.fontColor = .white
        healthLabel.position = CGPoint(x: 80, y: size.height - 110)
        healthLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(healthLabel)

        bossHealthLabel = SKLabelNode(text: "BOSS: ♥♥♥")
        bossHealthLabel.fontName = "Helvetica-Bold"
        bossHealthLabel.fontSize = 24
        bossHealthLabel.fontColor = .red
        bossHealthLabel.position = CGPoint(x: size.width - 150, y: size.height - 80)
        bossHealthLabel.horizontalAlignmentMode = .right
        cameraNode.addChild(bossHealthLabel)

        timeLabel = SKLabelNode(text: "Time: \(gameTime)")
        timeLabel.fontName = "Helvetica-Bold"
        timeLabel.fontSize = 24
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: 80, y: size.height - 140)
        timeLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(timeLabel)

        let pauseBtn = SKShapeNode(circleOfRadius: 22)
        pauseBtn.fillColor = SKColor(white: 0.1, alpha: 0.7)
        pauseBtn.strokeColor = SKColor(white: 0.8, alpha: 0.8)
        pauseBtn.lineWidth = 2
        pauseBtn.name = "pauseButton"
        pauseBtn.position = CGPoint(x: size.width - 45, y: size.height - 45)
        cameraNode.addChild(pauseBtn)

        let pauseIcon = SKLabelNode(text: "⏸")
        pauseIcon.fontSize = 20
        pauseIcon.fontColor = .white
        pauseIcon.name = "pauseButton"
        pauseIcon.position = CGPoint(x: 0, y: -7)
        pauseBtn.addChild(pauseIcon)
    }

    private func setupControlArea() {
        let buttonRadius: CGFloat = 50
        let buttonY: CGFloat = 90
        let buttonSpacing: CGFloat = 110
        let rightBaseX = size.width - 90

        // 左右移动按钮
        let (left, right) = GameUIBuilder.buildControlDpad(
            into: cameraNode,
            size: size,
            buttonRadius: buttonRadius,
            edgePadding: 20  // 基准值，实际位置用 leftBaseX/rightBaseX 覆盖
        )
        // BossScene 的 D-pad 位置与 GameScene 不同，用计算好的坐标直接修改
        left.position = CGPoint(x: 90, y: buttonY)
        right.position = CGPoint(x: 90 + buttonSpacing, y: buttonY)
        leftButton = left
        rightButton = right

        // 跳跃按钮
        jumpButton = GameUIBuilder.buildJumpButton(
            into: cameraNode,
            at: CGPoint(x: rightBaseX - buttonSpacing, y: buttonY),
            buttonRadius: buttonRadius
        )

        // 攻击按钮（ATK 标签）
        attackButton = GameUIBuilder.buildAttackButton(
            into: cameraNode,
            at: CGPoint(x: rightBaseX, y: buttonY),
            buttonRadius: buttonRadius
        )
        // BossScene 攻击按钮用文字标签，与 builder 默认的斧头不同，替换为 ATK 标签
        attackButton.children.filter { $0 is SKLabelNode }.forEach { $0.removeFromParent() }
        let attackLabel = SKLabelNode(text: "ATK")
        attackLabel.fontName = "Helvetica-Bold"
        attackLabel.fontSize = 22
        attackLabel.fontColor = .white
        attackLabel.position = CGPoint(x: 0, y: -6)
        attackButton.addChild(attackLabel)
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

    private func setupAudio() {
        AudioManager.shared.loadBGM("bgm_boss")
        AudioManager.shared.playBGM()
    }

    // MARK: - 暂停功能

    private func togglePause() {
        if pauseNode != nil {
            pauseNode.removeFromParent()
            pauseNode = nil
        } else {
            showPauseMenu()
        }
    }

    private func showPauseMenu() {
        pauseNode = SKNode()
        pauseNode.name = "pauseOverlay"
        pauseNode.position = .zero
        addChild(pauseNode)

        let overlay = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        overlay.fillColor = SKColor(white: 0, alpha: 0.6)
        overlay.strokeColor = .clear
        pauseNode.addChild(overlay)

        let title = SKLabelNode(text: "⏸ PAUSED")
        title.fontName = "Helvetica-Bold"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 60)
        pauseNode.addChild(title)

        let resumeBtn = SKShapeNode(rect: CGRect(x: -120, y: -20, width: 240, height: 60), cornerRadius: 10)
        resumeBtn.fillColor = SKColor(white: 0.2, alpha: 0.9)
        resumeBtn.strokeColor = SKColor(white: 0.8, alpha: 0.9)
        resumeBtn.lineWidth = 2
        resumeBtn.name = "resumeButton"
        pauseNode.addChild(resumeBtn)

        let resumeLabel = SKLabelNode(text: "RESUME")
        resumeLabel.fontName = "Helvetica-Bold"
        resumeLabel.fontSize = 24
        resumeLabel.fontColor = .white
        resumeLabel.name = "resumeButton"
        resumeLabel.position = CGPoint(x: 0, y: -6)
        resumeBtn.addChild(resumeLabel)

        let menuBtn = SKShapeNode(rect: CGRect(x: -120, y: -100, width: 240, height: 60), cornerRadius: 10)
        menuBtn.fillColor = SKColor(white: 0.15, alpha: 0.9)
        menuBtn.strokeColor = SKColor(white: 0.5, alpha: 0.9)
        menuBtn.lineWidth = 2
        menuBtn.name = "menuButton"
        pauseNode.addChild(menuBtn)

        let menuLabel = SKLabelNode(text: "MENU")
        menuLabel.fontName = "Helvetica-Bold"
        menuLabel.fontSize = 24
        menuLabel.fontColor = .white
        menuLabel.name = "menuButton"
        menuLabel.position = CGPoint(x: 0, y: -6)
        menuBtn.addChild(menuLabel)
    }

    private func returnToMenu() {
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .resizeFill
        view?.presentScene(menuScene, transition: SKTransition.flipHorizontal(withDuration: 0.5))
    }

    // MARK: - 触摸处理

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pauseNode != nil {
            for touch in touches {
                let location = touch.location(in: pauseNode!)
                let node = pauseNode!.atPoint(location)
                switch node.name {
                case "resumeButton":
                    pauseNode.removeFromParent()
                    pauseNode = nil
                case "menuButton":
                    returnToMenu()
                default:
                    break
                }
            }
            return
        }

        for touch in touches {
            let location = touch.location(in: cameraNode!)
            let node = cameraNode!.atPoint(location)
            let buttonName: String?
            switch node.name {
            case "pauseButton":  buttonName = "pauseButton"
            case "leftButton":   buttonName = "leftButton"
            case "rightButton":  buttonName = "rightButton"
            case "jumpButton":   buttonName = "jumpButton"
            case "attackButton": buttonName = "attackButton"
            default:             buttonName = nil
            }
            if let name = buttonName {
                activeTouches[touch.hash] = name
                handleButtonDown(name)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let name = activeTouches[touch.hash] {
                handleButtonUp(name)
            }
            activeTouches.removeValue(forKey: touch.hash)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let name = activeTouches[touch.hash] {
                handleButtonUp(name)
            }
            activeTouches.removeValue(forKey: touch.hash)
        }
    }

    private func handleButtonDown(_ name: String) {
        switch name {
        case "pauseButton":  togglePause()
        case "leftButton":   isLeftPressed = true
        case "rightButton":  isRightPressed = true
        case "jumpButton":
            isJumpPressed = true
            isJumpConsumed = false
        case "attackButton":
            isAttackPressed = true
            isAttackConsumed = false
        default: break
        }
    }

    private func handleButtonUp(_ name: String) {
        switch name {
        case "leftButton":   isLeftPressed = false
        case "rightButton":  isRightPressed = false
        case "jumpButton":
            isJumpPressed = false
            isJumpConsumed = false
        case "attackButton":
            isAttackPressed = false
            isAttackConsumed = false
        default: break
        }
    }

    // MARK: - 更新逻辑

    override func update(_ currentTime: TimeInterval) {
        if pauseNode != nil { return }
        guard !isGameOver && !isVictory else { return }

        if isLeftPressed {
            player.moveLeft()
        } else if isRightPressed {
            player.moveRight()
        } else {
            player.stop()
        }

        if isJumpPressed && !isJumpConsumed {
            player.jump()
            isJumpConsumed = true
        }

        if isAttackPressed && !isAttackConsumed {
            player.attack()
            checkAttackHit()
            isAttackConsumed = true
        }

        boss.update(playerPosition: player.position)
        cameraNode.position.x = (player.position.x + boss.position.x) / 2
        player.update()
    }

    // MARK: - 战斗逻辑

    private func checkAttackHit() {
        let attackRange = CGRect(x: player.position.x - Constants.attackRange * 0.8, y: player.position.y - 30, width: Constants.attackRange * 1.6, height: 60)
        if attackRange.intersects(boss.attackHitbox) {
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

    private func addScore(_ points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
    }

    private func takeDamage() {
        guard !damageCooldown && !isGameOver && !isVictory else { return }
        damageCooldown = true
        health -= 1
        healthLabel.text = "Health: \(health)"
        player.takeDamage()
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.damageCooldown) { [weak self] in
            self?.damageCooldown = false
        }
        if health <= 0 {
            gameOver()
        }
    }

    private func gameOver() {
        isGameOver = true
        let gameOverScene = GameOverScene(size: size, score: score)
        gameOverScene.scaleMode = .resizeFill
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
        levelCompleteScene.scaleMode = .resizeFill
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(levelCompleteScene, transition: transition)
    }

    // MARK: - SKPhysicsContactDelegate

    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        if maskA == PhysicsCategories.player && maskB == PhysicsCategories.ground {
            player?.didContact(with: PhysicsCategories.ground)
        } else if maskB == PhysicsCategories.player && maskA == PhysicsCategories.ground {
            player?.didContact(with: PhysicsCategories.ground)
        } else if maskA == PhysicsCategories.player && maskB == PhysicsCategories.enemy {
            takeDamage()
        } else if maskB == PhysicsCategories.player && maskA == PhysicsCategories.enemy {
            takeDamage()
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        if maskA == PhysicsCategories.player && maskB == PhysicsCategories.ground {
            player?.didEndContact(with: PhysicsCategories.ground)
        } else if maskB == PhysicsCategories.player && maskA == PhysicsCategories.ground {
            player?.didEndContact(with: PhysicsCategories.ground)
        }
    }
}