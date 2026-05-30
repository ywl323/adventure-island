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
            let config = LevelManager.shared.getLevelConfig(levelNumber)
            let terrain: String = config?.terrainType ?? "grass"
            let eCount: Int = config?.enemyCount ?? 3
            let iCount: Int = config?.itemCount ?? 10
            let levelWidth: CGFloat = config?.width ?? 3000
            let diff: Int = config?.difficulty ?? 1

            // 敌人
            var enemySpawns: [EnemySpawnData] = []
            for idx in 0..<eCount {
                let seedY: UInt64 = UInt64(levelNumber &* 0x9E3779B97F4A7C15 &+ UInt64(idx &* 17 &+ 1))
                let fnY: () -> Int = makeSeededRandom(seed: seedY)
                let yRaw: Int = fnY()
                let posX: CGFloat = CGFloat(idx + 1) * (levelWidth / CGFloat(eCount + 1))
                let posY: CGFloat = CGFloat(yRaw % 200 + 100)

                let seedT: UInt64 = UInt64(levelNumber &* 0x9E3779B97F4A7C15 &+ UInt64(idx &* 7))
                let fnT: () -> Int = makeSeededRandom(seed: seedT)
                let rVal: Int = fnT()
                let enemyKind: String = Self.terrainEnemyTypeInline(terrain: terrain, rand: rVal)

                enemySpawns.append(EnemySpawnData(x: posX, y: posY, type: enemyKind))
            }

            // 物品
            var itemSpawns: [ItemSpawnData] = []
            for idx in 0..<iCount {
                let seedY: UInt64 = UInt64(levelNumber &* 0x9E3779B97F4A7C15 &+ UInt64(idx &* 11 &+ 1001))
                let fnY: () -> Int = makeSeededRandom(seed: seedY)
                let yRaw: Int = fnY()
                let posX: CGFloat = CGFloat(idx + 1) * (levelWidth / CGFloat(iCount + 1))
                let posY: CGFloat = CGFloat(yRaw % 120 + 80)

                let seedT: UInt64 = UInt64(levelNumber &* 0x9E3779B97F4A7C15 &+ UInt64(idx &* 5 &+ 2000))
                let fnT: () -> Int = makeSeededRandom(seed: seedT)
                let rVal: Int = fnT()
                let itemKind: String = Self.difficultyItemTypeInline(difficulty: diff, rand: rVal)

                itemSpawns.append(ItemSpawnData(x: posX, y: posY, type: itemKind))
            }

            result[levelNumber] = LevelSpawnData(enemies: enemySpawns, items: itemSpawns)
        }

        return result
    }

    // MARK: - 工具方法（与 LevelManager 内部逻辑一致）
    private static func terrainEnemyType(at index: Int, terrain: String, randFunc: () -> Int) -> String {
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
        return types[abs(randFunc()) % types.count]
    }

    private static func difficultyItemTypeInline(difficulty: Int, rand: Int) -> String {
        let easyItems = ["coin", "fruit", "health"]
        let mediumItems = ["coin", "fruit", "health", "powerup", "egg"]
        let hardItems = ["coin", "egg", "diamond", "powerup", "health"]
        let items: [String] = difficulty <= 2 ? easyItems : (difficulty <= 4 ? mediumItems : hardItems)
        let idx: Int = abs(rand) % items.count
        return items[idx]
    }
}