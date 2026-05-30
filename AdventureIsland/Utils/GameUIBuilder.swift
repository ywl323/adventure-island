import SpriteKit

/// GameScene 和 BossScene 共用的 UI 构建工具
/// 统一管理 D-pad 按钮、跳跃/攻击按钮、HUD 标签的创建逻辑
/// 使用方式：GameUIBuilder.buildControlDpad(into: cameraNode, size: scene.size)
struct GameUIBuilder {

    // MARK: - D-pad 左右移动按钮

    static func buildControlDpad(
        into parent: SKNode,
        size: CGSize,
        buttonRadius: CGFloat = 50,
        edgePadding: CGFloat = 20,
        leftButtonName: String = "leftButton",
        rightButtonName: String = "rightButton"
    ) -> (left: SKNode, right: SKNode) {

        let buttonY = -size.height / 2 + edgePadding + buttonRadius

        // 左按钮
        let leftBtn = SKNode()
        leftBtn.name = leftButtonName
        leftBtn.position = CGPoint(x: -size.width / 2 + edgePadding + buttonRadius, y: buttonY)
        let leftBg = SKShapeNode(circleOfRadius: buttonRadius / 2)
        leftBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        leftBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        leftBg.lineWidth = 2.5
        leftBtn.addChild(leftBg)

        let leftPath = CGMutablePath()
        leftPath.move(to: CGPoint(x: -8, y: 0))
        leftPath.addLine(to: CGPoint(x: 8, y: -10))
        leftPath.addLine(to: CGPoint(x: 8, y: 10))
        leftPath.closeSubpath()
        let leftArrow = SKShapeNode(path: leftPath)
        leftArrow.fillColor = .white
        leftArrow.strokeColor = .clear
        leftBtn.addChild(leftArrow)
        parent.addChild(leftBtn)

        // 右按钮
        let rightBtn = SKNode()
        rightBtn.name = rightButtonName
        rightBtn.position = CGPoint(x: -size.width / 2 + edgePadding + buttonRadius * 1.6, y: buttonY)
        let rightBg = SKShapeNode(circleOfRadius: buttonRadius / 2)
        rightBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        rightBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        rightBg.lineWidth = 2.5
        rightBtn.addChild(rightBg)

        let rightPath = CGMutablePath()
        rightPath.move(to: CGPoint(x: 8, y: 0))
        rightPath.addLine(to: CGPoint(x: -8, y: -10))
        rightPath.addLine(to: CGPoint(x: -8, y: 10))
        rightPath.closeSubpath()
        let rightArrow = SKShapeNode(path: rightPath)
        rightArrow.fillColor = .white
        rightArrow.strokeColor = .clear
        rightBtn.addChild(rightArrow)
        parent.addChild(rightBtn)

        return (leftBtn, rightBtn)
    }

    // MARK: - 跳跃按钮

    static func buildJumpButton(
        into parent: SKNode,
        at position: CGPoint,
        buttonRadius: CGFloat = 50,
        name: String = "jumpButton"
    ) -> SKNode {
        let jumpBtn = SKNode()
        jumpBtn.name = name
        jumpBtn.position = position
        let jumpBg = SKShapeNode(circleOfRadius: buttonRadius / 2)
        jumpBg.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.5, alpha: 0.85)
        jumpBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        jumpBg.lineWidth = 2.5
        jumpBtn.addChild(jumpBg)

        let jumpPath = CGMutablePath()
        jumpPath.move(to: CGPoint(x: 0, y: 14))
        jumpPath.addLine(to: CGPoint(x: -14, y: -8))
        jumpPath.addLine(to: CGPoint(x: 14, y: -8))
        jumpPath.closeSubpath()
        let jumpArrow = SKShapeNode(path: jumpPath)
        jumpArrow.fillColor = .white
        jumpArrow.strokeColor = .clear
        jumpBtn.addChild(jumpArrow)
        parent.addChild(jumpBtn)
        return jumpBtn
    }

    // MARK: - 攻击按钮

    static func buildAttackButton(
        into parent: SKNode,
        at position: CGPoint,
        buttonRadius: CGFloat = 50,
        name: String = "attackButton"
    ) -> SKNode {
        let attackBtn = SKNode()
        attackBtn.name = name
        attackBtn.position = position
        let attackBg = SKShapeNode(circleOfRadius: buttonRadius / 2)
        attackBg.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.85)
        attackBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        attackBg.lineWidth = 2.5
        attackBtn.addChild(attackBg)

        // 优先使用 fireball 精灵，否则用 ShapeNode 画斧头
        let fireballSprite = SKSpriteNode(imageNamed: "32_projectile_fireball")
        if fireballSprite.texture != nil {
            fireballSprite.size = CGSize(width: 36, height: 36)
            fireballSprite.zPosition = 1
            attackBtn.addChild(fireballSprite)
        } else {
            let atkPath = CGMutablePath()
            atkPath.move(to: CGPoint(x: 0, y: 14))
            atkPath.addLine(to: CGPoint(x: -14, y: -10))
            atkPath.addLine(to: CGPoint(x: 0, y: -2))
            atkPath.addLine(to: CGPoint(x: 14, y: -10))
            atkPath.closeSubpath()
            let atkSymbol = SKShapeNode(path: atkPath)
            atkSymbol.fillColor = .white
            atkSymbol.strokeColor = .clear
            attackBtn.addChild(atkSymbol)
        }
        parent.addChild(attackBtn)
        return attackBtn
    }

    // MARK: - 暂停按钮

    static func buildPauseButton(
        into parent: SKNode,
        at position: CGPoint,
        size: CGFloat = 36,
        name: String = "pauseButton"
    ) -> SKNode {
        let pauseBtn = SKNode()
        pauseBtn.name = name
        pauseBtn.position = position
        let pauseBg = SKShapeNode(rect: CGRect(x: -size / 2, y: -size / 2, width: size, height: size), cornerRadius: 8)
        pauseBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        pauseBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        pauseBg.lineWidth = 2
        pauseBtn.addChild(pauseBg)

        let bar1 = SKShapeNode(rect: CGRect(x: -7, y: -8, width: 5, height: 16))
        bar1.fillColor = .white
        bar1.strokeColor = .clear
        pauseBtn.addChild(bar1)

        let bar2 = SKShapeNode(rect: CGRect(x: 2, y: -8, width: 5, height: 16))
        bar2.fillColor = .white
        bar2.strokeColor = .clear
        pauseBtn.addChild(bar2)

        parent.addChild(pauseBtn)
        return pauseBtn
    }

    // MARK: - HUD 标签（基础样式）

    static func makeHUDLabel(
        text: String,
        fontSize: CGFloat,
        color: SKColor = .white,
        position: CGPoint,
        alignment: SKLabelHorizontalAlignmentMode = .left
    ) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Helvetica-Bold"
        label.fontSize = fontSize
        label.fontColor = color
        label.position = position
        label.horizontalAlignmentMode = alignment
        return label
    }
}
