import Foundation

struct PhysicsCategories {

    // MARK: - 碰撞检测位掩码

    /// 无碰撞（空类别）
    static let none: UInt32 = 0

    /// 玩家
    static let player: UInt32 = 0x1 << 0       // 1

    /// 地面/平台
    static let ground: UInt32 = 0x1 << 1        // 2

    /// 敌人
    static let enemy: UInt32 = 0x1 << 2         // 4

    /// 物品（金币、道具等）
    static let item: UInt32 = 0x1 << 3          // 8

    /// 武器/攻击
    static let weapon: UInt32 = 0x1 << 4        // 16

    /// 场景边界
    static let boundary: UInt32 = 0x1 << 5      // 32

    /// 触发器（隐藏区域）
    static let trigger: UInt32 = 0x1 << 6       // 64

    /// 终点/目标区域
    static let goal: UInt32 = 0x1 << 7         // 128

    // MARK: - 便捷组合

    /// 所有实体类别
    static let allEntities: UInt32 = player | ground | enemy | item

    /// 可以与玩家碰撞的物体
    static let playerCollidable: UInt32 = ground | enemy | item

    /// 可以与敌人碰撞的物体
    static let enemyCollidable: UInt32 = player | ground | weapon
}
