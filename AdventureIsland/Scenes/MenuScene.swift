import SpriteKit

class MenuScene: SKScene {

    private var titleLabel: SKLabelNode!
    private var startButton: SKLabelNode!
    private var worldLabel: SKLabelNode!
    private var currentWorldIndex: Int = 0
    // 当前选中的关卡索引（0-3），用于关卡选择
    private var selectedLevelIndex: Int = 0

    // 左右箭头按钮节点
    private var leftArrowNode: SKNode!
    private var rightArrowNode: SKNode!

    override func didMove(to view: SKView) { super.didMove(to: view); 
        print("🔥 MenuScene.didMove called! size=\(size)")
        backgroundColor = SKColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0)
        print("   view.bounds: \(view.bounds)")

        // 背景渐变层
        let gradient = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        gradient.fillColor = SKColor(red: 0.05, green: 0.1, blue: 0.25, alpha: 1.0)
        gradient.strokeColor = .clear
        gradient.zPosition = -99
        addChild(gradient)

        setupBackground()
        setupTitle()
        setupWorldSelector()
        setupStartButton()
    }

    private func setupBackground() {
        // 星空背景
        for _ in 0..<100 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...4))
            star.fillColor = SKColor(white: CGFloat.random(in: 0.4...1.0), alpha: 1.0)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.2...0.9)
            star.zPosition = -80
            addChild(star)
        }

        // 地面
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: 80))
        ground.fillColor = SKColor(red: 0.15, green: 0.45, blue: 0.15, alpha: 1.0)
        ground.strokeColor = .clear
        ground.zPosition = -50
        addChild(ground)

        // 棕榈树装饰
        for i in 0..<Int(size.width / 250) {
            let tree = createPalmTree()
            tree.position = CGPoint(x: CGFloat(i) * 250 + 80, y: 60)
            tree.zPosition = -30
            addChild(tree)
        }
    }

    private func createPalmTree() -> SKNode {
        let tree = SKNode()

        // 树干（棕色梯形）
        let trunkPath = CGMutablePath()
        trunkPath.move(to: CGPoint(x: -8, y: 0))
        trunkPath.addLine(to: CGPoint(x: 8, y: 0))
        trunkPath.addLine(to: CGPoint(x: 5, y: 70))
        trunkPath.addLine(to: CGPoint(x: -5, y: 70))
        trunkPath.closeSubpath()
        let trunk = SKShapeNode(path: trunkPath)
        trunk.fillColor = SKColor(red: 0.45, green: 0.28, blue: 0.1, alpha: 1.0)
        trunk.strokeColor = .clear
        tree.addChild(trunk)

        // 树冠（扇形叶片用多个椭圆组成）
        let leafColor = SKColor(red: 0.15, green: 0.55, blue: 0.15, alpha: 1.0)
        let leafColor2 = SKColor(red: 0.2, green: 0.65, blue: 0.2, alpha: 1.0)

        for i in 0..<7 {
            let angle = CGFloat(i) / 7.0 * .pi * 2
            let leaf = SKShapeNode(ellipseOf: CGSize(width: 12, height: 40))
            leaf.fillColor = i % 2 == 0 ? leafColor : leafColor2
            leaf.strokeColor = .clear
            leaf.zRotation = angle
            leaf.position = CGPoint(x: 0, y: 75)
            tree.addChild(leaf)
        }

        return tree
    }

    private func setupTitle() {
        titleLabel = SKLabelNode(text: "ADVENTURE ISLAND")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = min(size.width * 0.06, 60)
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)

        let subtitleLabel = SKLabelNode(text: "🏝️ 16 Epic Levels 🏝️")
        subtitleLabel.fontName = "Helvetica"
        subtitleLabel.fontSize = min(size.width * 0.025, 24)
        subtitleLabel.fontColor = SKColor(white: 0.7, alpha: 1.0)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.74)
        subtitleLabel.horizontalAlignmentMode = .center
        addChild(subtitleLabel)
    }

    private func setupWorldSelector() {
        // 世界名标签（放中间）
        worldLabel = SKLabelNode(text: getCurrentWorldText())
        worldLabel.fontName = "Helvetica-Bold"
        worldLabel.fontSize = min(size.width * 0.035, 36)
        worldLabel.fontColor = .yellow
        worldLabel.name = "worldLabel"
        worldLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        worldLabel.horizontalAlignmentMode = .center
        addChild(worldLabel)

        // 关卡数字（世界名下方）
        let levelRangeLabel = SKLabelNode(text: getLevelRangeText())
        levelRangeLabel.fontName = "Helvetica"
        levelRangeLabel.fontSize = min(size.width * 0.022, 20)
        levelRangeLabel.fontColor = SKColor(white: 0.6, alpha: 1.0)
        levelRangeLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.53)
        levelRangeLabel.horizontalAlignmentMode = .center
        addChild(levelRangeLabel)

        // 左箭头按钮（世界名左侧，y偏下）
        leftArrowNode = SKNode()
        leftArrowNode.name = "leftArrow"
        leftArrowNode.position = CGPoint(x: size.width * 0.18, y: size.height * 0.6)
        let leftBg = SKShapeNode(circleOfRadius: 30)
        leftBg.fillColor = SKColor(white: 0.15, alpha: 0.8)
        leftBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        leftBg.lineWidth = 2
        leftArrowNode.addChild(leftBg)

        // 左箭头按钮（世界名左侧，y偏下）
        // ◀ 箭头（指向左）
        let leftPath = CGMutablePath()
        leftPath.move(to: CGPoint(x: -8, y: 0))
        leftPath.addLine(to: CGPoint(x: 8, y: -10))
        leftPath.addLine(to: CGPoint(x: 8, y: 10))
        leftPath.closeSubpath()
        let leftArrow = SKShapeNode(path: leftPath)
        leftArrow.fillColor = .white
        leftArrow.strokeColor = .clear
        leftArrowNode.addChild(leftArrow)
        addChild(leftArrowNode)

        // 右箭头按钮（世界名右侧）
        rightArrowNode = SKNode()
        rightArrowNode.name = "rightArrow"
        rightArrowNode.position = CGPoint(x: size.width * 0.82, y: size.height * 0.6)
        let rightBg = SKShapeNode(circleOfRadius: 30)
        rightBg.fillColor = SKColor(white: 0.15, alpha: 0.8)
        rightBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        rightBg.lineWidth = 2
        rightArrowNode.addChild(rightBg)
        // ▶ 箭头（指向右）
        let rightPath = CGMutablePath()
        rightPath.move(to: CGPoint(x: 8, y: 0))
        rightPath.addLine(to: CGPoint(x: -8, y: -10))
        rightPath.addLine(to: CGPoint(x: -8, y: 10))
        rightPath.closeSubpath()
        let rightArrow = SKShapeNode(path: rightPath)
        rightArrow.fillColor = .white
        rightArrow.strokeColor = .clear
        rightArrowNode.addChild(rightArrow)
        addChild(rightArrowNode)

        // 关卡指示器（1-4 小圆点，在世界名下方）
        updateLevelIndicators()
    }

    private func updateLevelIndicators() {
        children.filter { $0.name?.starts(with: "levelDot") == true }.forEach { $0.removeFromParent() }

        let world = LevelManager.shared.worlds[currentWorldIndex]
        let startLevel = world.startLevel
        let highestUnlocked = GameData.shared.highestUnlockedLevel

        let dotY = size.height * 0.46
        let dotSpacing: CGFloat = 44
        let startX = size.width / 2 - dotSpacing * 1.5

        for i in 0..<4 {
            let levelNum = startLevel + i
            let isUnlocked = levelNum <= highestUnlocked
            let isSelected = (i == selectedLevelIndex)

            let dot = SKShapeNode(circleOfRadius: 14)
            if isUnlocked {
                dot.fillColor = isSelected ? .yellow : SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
                dot.strokeColor = .white
            } else {
                dot.fillColor = SKColor(white: 0.2, alpha: 0.8)
                dot.strokeColor = SKColor(white: 0.4, alpha: 0.5)
            }
            dot.lineWidth = 1.5
            dot.name = "levelDot\(i)"
            dot.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: dotY)
            addChild(dot)

            let numLabel = SKLabelNode(text: isUnlocked ? "\(levelNum)" : "🔒")
            numLabel.fontName = "Helvetica-Bold"
            numLabel.fontSize = isUnlocked ? 14 : 11
            numLabel.fontColor = isUnlocked ? (isSelected ? .black : SKColor(white: 0.9, alpha: 1.0)) : SKColor(white: 0.5, alpha: 1.0)
            numLabel.name = "levelNum\(i)"
            numLabel.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: dotY - 5)
            numLabel.verticalAlignmentMode = .center
            addChild(numLabel)
        }
    }

    private func getCurrentWorldText() -> String {
        let world = LevelManager.shared.worlds[currentWorldIndex]
        return "World \(world.worldNumber): \(world.name)"
    }

    private func getLevelRangeText() -> String {
        let world = LevelManager.shared.worlds[currentWorldIndex]
        return "Levels \(world.startLevel)-\(world.startLevel + 3)"
    }

    private func setupStartButton() {
        // 使用带命中背景的父节点，避免文字过小导致难以点击
        let btnY = size.height * 0.28

        let startBg = SKShapeNode(rect: CGRect(x: -110, y: -25, width: 220, height: 50), cornerRadius: 12)
        startBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.85)
        startBg.strokeColor = SKColor(white: 0.4, alpha: 0.7)
        startBg.lineWidth = 2
        startBg.name = "startButton"
        startBg.position = CGPoint(x: size.width / 2, y: btnY)
        addChild(startBg)

        startButton = SKLabelNode(text: "▶ START")
        startButton.fontName = "Helvetica-Bold"
        startButton.fontSize = min(size.width * 0.04, 40)
        startButton.fontColor = .white
        startButton.position = CGPoint(x: 0, y: -7)
        startBg.addChild(startButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = self.atPoint(location)

        if node.name == "startButton" {
            startSelectedLevel()
        } else if node.name?.starts(with: "levelDot") == true {
            handleLevelDotTap(at: node.name!)
        } else if node.name == "leftArrow" || (node.parent != nil && node.parent?.name == "leftArrow") {
            currentWorldIndex = (currentWorldIndex - 1 + LevelManager.shared.worlds.count) % LevelManager.shared.worlds.count
            selectedLevelIndex = 0
            updateWorldLabel()
            updateLevelIndicators()
        } else if node.name == "rightArrow" || (node.parent != nil && node.parent?.name == "rightArrow") {
            currentWorldIndex = (currentWorldIndex + 1) % LevelManager.shared.worlds.count
            selectedLevelIndex = 0
            updateWorldLabel()
            updateLevelIndicators()
        }
    }

    private func updateWorldLabel() {
        worldLabel?.text = getCurrentWorldText()
    }

    // MARK: - Level Selection

    private func handleLevelDotTap(at dotName: String) {
        guard let indexStr = dotName.replacingOccurrences(of: "levelDot", with: "") as String?,
              let index = Int(indexStr) else { return }

        let world = LevelManager.shared.worlds[currentWorldIndex]
        let levelNum = world.startLevel + index
        let highestUnlocked = GameData.shared.highestUnlockedLevel

        if levelNum <= highestUnlocked {
            selectedLevelIndex = index
            updateLevelIndicators()
        } else {
            // Show locked feedback
            let label = SKLabelNode(text: "🔒 Complete Level \(highestUnlocked) first!")
            label.fontName = "Helvetica-Bold"
            label.fontSize = 20
            label.fontColor = .red
            label.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
            label.alpha = 0
            label.zPosition = 100
            addChild(label)

            let fade = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            let wait = SKAction.wait(forDuration: 1.5)
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
            let remove = SKAction.removeFromParent()
            label.run(SKAction.sequence([fade, wait, fadeOut, remove]))
        }
    }

    private func startSelectedLevel() {
        let world = LevelManager.shared.worlds[currentWorldIndex]
        let levelNum = world.startLevel + selectedLevelIndex
        print("🎮 startSelectedLevel: level=\(levelNum), world=\(currentWorldIndex), index=\(selectedLevelIndex)")
        let levelData = LevelManager.shared.generateLevelData(levelNum)
        print("📦 levelData: \(levelData.levelNumber), terrain=\(levelData.terrainType), width=\(levelData.width)")

        let gameScene: SKScene
        if levelData.terrainType == "boss" {
            print("→ BossScene")
            gameScene = BossScene(size: size, levelData: levelData)
        } else {
            print("→ GameScene")
            gameScene = GameScene(size: size, levelData: levelData)
        }

        gameScene.scaleMode = .resizeFill
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
}