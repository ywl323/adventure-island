import Foundation

/// 关卡随机种子存储 — 保证同一关卡每次进入的敌人/物品位置完全相同
/// 使用 levelNumber 作为种子，通过确定性随机生成固定位置
struct LevelSeedStorage {

    // MARK: - 单条关卡的预生成数据
    struct LevelSpawnData {
        let enemies: [EnemySpawnData]
        let items: [ItemSpawnData]
    }

    // MARK: - 全部预生成数据（按 levelNumber 索引）
    private static let seedData: [Int: LevelSpawnData] = {
        generateAllSeeds()
    }()

    // MARK: - 按 levelNumber 获取预生成数据
    static func getSpawnData(for levelNumber: Int) -> LevelSpawnData? {
        return seedData[levelNumber]
    }

    // MARK: - 确定性随机生成器（使用线性同余生成器）
    private static func makeSeededRandom(seed: UInt64) -> () -> Int {
        var s = seed
        return {
            s = s &* 6364136223846793005 &+ 1442695040888963407
            return Int(truncatingIfNeeded: s >> 33)
        }
    }

    // MARK: - 为主世界1~12 每个 levelNumber 生成确定性数据
    private static func generateAllSeeds() -> [Int: LevelSpawnData] {
        var result: [Int: LevelSpawnData] = [:]

        for levelNumber in 1...12 {
            let rand = makeSeededRandom(seed: UInt64(levelNumber * 0x9E3779B97F4A7C15))

            // 根据 levelNumber 查配置得到 terrainType/enemyCount/itemCount
            let config = LevelManager.shared.getLevelConfig(levelNumber)
            let terrainType = config?.terrainType ?? "grass"
            let enemyCount = config?.enemyCount ?? 3
            let itemCount = config?.itemCount ?? 10
            let width = config?.width ?? 3000

            // 敌人位置（确定性伪随机，均匀分布）
            var enemies: [EnemySpawnData] = []
            for i in 0..<enemyCount {
                // 用 i 和 levelNumber 混合种子，避免每次循环用同一个 rand 产生相同值
                let r2 = makeSeededRandom(seed: UInt64(levelNumber &* 0x9E3779B97F4A7C15 &+ UInt64(i &* 17 &+ 1)))
                let x = CGFloat(i + 1) * (width / CGFloat(enemyCount + 1))
                let yRand = r2()
                let y = CGFloat(yRand % 200 + 100)  // 100~300 范围
                let enemyRand = makeSeededRandom(seed: UInt64(levelNumber &* 0x9E3779B97F4A7C15 &+ UInt64(i &* 7)))
                let type = terrainEnemyType(at: i, terrain: terrainType, rand: enemyRand)
                enemies.append(EnemySpawnData(x: x, y: y, type: type))
            }

            // 物品位置（确定性伪随机）
            var items: [ItemSpawnData] = []
            for i in 0..<itemCount {
                let r2 = makeSeededRandom(seed: UInt64(levelNumber &* 0x9E3779B97F4A7C15 &+ UInt64(i &* 11 &+ 1001)))
                let x = CGFloat(i + 1) * (width / CGFloat(itemCount + 1))
                let yRand = r2()
                let y = CGFloat(yRand % 120 + 80)  // 80~200 范围
                let itemRand = makeSeededRandom(seed: UInt64(levelNumber &* 0x9E3779B97F4A7C15 &+ UInt64(i &* 5 &+ 2000)))
                let type = difficultyItemType(at: i, difficulty: config?.difficulty ?? 1, rand: itemRand)
                items.append(ItemSpawnData(x: x, y: y, type: type))
            }

            result[levelNumber] = LevelSpawnData(enemies: enemies, items: items)
        }

        return result
    }

    // MARK: - 工具方法（与 LevelManager 内部逻辑一致）
    private static func terrainEnemyType(at index: Int, terrain: String, rand: () -> Int) -> String {
        let baseTypes = ["basic", "flying", "fast"]
        let terrainTypes: [String: [String]] = [
            "grass": ["dinosaur", "snail", "seagull", "bee", "lizard"],
            "water": ["piranha", "lizard", "snake"],
            "underground": ["bat", "skeleton", "scorpion", "worm"],
            "volcano": ["fire_lizard", "fire_skeleton", "volcanic_bat", "magma_sprite"],
            "sky": ["sky_knight", "thunder_orb", "guardian_angel"],
            "cliff": ["storm_vulture", "lightning_lizard"],
            "ruins": ["guardian_statue", "curse_ghost", "ancient_beetle"],
            "boss": []
        ]
        let types = terrainTypes[terrain] ?? baseTypes
        return types[abs(rand()) % types.count]
    }

    private static func difficultyItemType(at index: Int, difficulty: Int, rand: () -> Int) -> String {
        let easyItems = ["coin", "fruit", "health"]
        let mediumItems = ["coin", "fruit", "health", "powerup", "egg"]
        let hardItems = ["coin", "egg", "diamond", "powerup", "health"]
        let items = difficulty <= 2 ? easyItems : (difficulty <= 4 ? mediumItems : hardItems)
        return items[abs(rand()) % items.count]
    }
}