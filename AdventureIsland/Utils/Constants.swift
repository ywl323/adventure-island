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
}
