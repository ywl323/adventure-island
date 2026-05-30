import Foundation
import CoreGraphics

struct Constants {

    // MARK: - 游戏帧率
    static let targetFPS: Int = 60

    // MARK: - 物理参数
    static let gravity: CGFloat = 1200.0         // 重力加速度
    static let jumpForce: CGFloat = 420.0        // 跳跃力度
    static let playerSpeed: CGFloat = 300.0      // 玩家移动速度

    // MARK: - 屏幕尺寸
    static let screenWidth: CGFloat = 1024.0     // 横屏基准宽度
    static let screenHeight: CGFloat = 576.0     // 横屏基准高度

    // MARK: - 相机参数
    static let cameraLag: CGFloat = 0.1          // 相机跟随延迟

    // MARK: - 游戏参数
    static let defaultLives: Int = 3             // 默认生命数
    static let defaultScore: Int = 0             // 默认分数
    static let defaultTimeLimit: Int = 60       // 默认时间限制（秒）

    // MARK: - 敌人参数
    static let basicEnemySpeed: CGFloat = 100.0
    static let flyingEnemySpeed: CGFloat = 150.0
    static let bossSpeed: CGFloat = 50.0

    // MARK: - 动画时长
    static let attackAnimationDuration: TimeInterval = 0.3
    static let deathAnimationDuration: TimeInterval = 1.0
    static let transitionDuration: TimeInterval = 0.5

    // MARK: - 玩家参数
    static let playerPhysicsRadius: CGFloat = 20.0    // 碰撞体半径
    static let playerSpriteScale: CGFloat = 0.15     // 精灵缩放比例
    static let jumpCooldown: TimeInterval = 0.5       // 跳跃冷却时间
    static let attackDuration: TimeInterval = 0.5     // 攻击动作持续时间
    static let attackMoveDistance: CGFloat = 180.0   // 斧子飞行的水平距离
    static let attackMoveHeight: CGFloat = 40.0      // 斧子飞行的垂直高度
    static let attackFinishDelay: TimeInterval = 0.3  // 攻击结束延迟

    // MARK: - 战斗参数
    static let attackRange: CGFloat = 60.0           // 玩家攻击判定范围
    static let attackCooldown: TimeInterval = 0.4     // 攻击命中冷却（防止一次攻击重复判定）
    static let damageCooldown: TimeInterval = 1.5     // 受伤后无敌时间

    // MARK: - 游戏逻辑参数
    static let playerStartX: CGFloat = 200.0         // 玩家初始X坐标
    static let playerStartY: CGFloat = 150.0         // 玩家初始Y坐标
    static let maxHealth: Int = 3                    // 最大生命值
}
