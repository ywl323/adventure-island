import Foundation

class LevelManager {

    // MARK: - 单例
    static let shared = LevelManager()
    private init() {}

    // MARK: - 关卡配置
    struct LevelConfig {
        let levelNumber: Int
        let name: String
        let width: CGFloat
        let enemyCount: Int
        let itemCount: Int
        let timeLimit: Int
        let backgroundMusic: String
        let terrainType: String  // grass, water, underground, volcano, sky, boss, cliff, ruins
        let difficulty: Int      // 1-5 stars
        let specialFeature: String // wind, lava, swamp, etc.
    }

    // 预定义16个关卡
    let levelConfigs: [LevelConfig] = [
        // ===== 世界1：初学者之岛 =====
        LevelConfig(levelNumber: 1, name: "Green Hills", width: 3000, enemyCount: 3, itemCount: 10, timeLimit: 120,
                    backgroundMusic: "bgm_world1", terrainType: "grass", difficulty: 1, specialFeature: "none"),
        LevelConfig(levelNumber: 2, name: "Coastal Path", width: 3500, enemyCount: 5, itemCount: 15, timeLimit: 150,
                    backgroundMusic: "bgm_world1", terrainType: "water", difficulty: 1, specialFeature: "bridges"),
        LevelConfig(levelNumber: 3, name: "Thicket Forest", width: 4500, enemyCount: 8, itemCount: 20, timeLimit: 150,
                    backgroundMusic: "bgm_world1", terrainType: "underground", difficulty: 2, specialFeature: "underground_entrance"),
        LevelConfig(levelNumber: 4, name: "Raptor King", width: 2000, enemyCount: 1, itemCount: 8, timeLimit: 90,
                    backgroundMusic: "bgm_boss", terrainType: "boss", difficulty: 2, specialFeature: "boss_raptor"),

        // ===== 世界2：热带丛林 =====
        LevelConfig(levelNumber: 5, name: "Vine Jungle", width: 5000, enemyCount: 8, itemCount: 18, timeLimit: 150,
                    backgroundMusic: "bgm_world2", terrainType: "grass", difficulty: 2, specialFeature: "vines"),
        LevelConfig(levelNumber: 6, name: "River Adventure", width: 5500, enemyCount: 10, itemCount: 22, timeLimit: 180,
                    backgroundMusic: "bgm_world2", terrainType: "water", difficulty: 2, specialFeature: "raft"),
        LevelConfig(levelNumber: 7, name: "Hidden Cave", width: 6000, enemyCount: 12, itemCount: 25, timeLimit: 210,
                    backgroundMusic: "bgm_world2", terrainType: "underground", difficulty: 3, specialFeature: "rising_water"),
        LevelConfig(levelNumber: 8, name: "Giant Frog", width: 2500, enemyCount: 1, itemCount: 10, timeLimit: 150,
                    backgroundMusic: "bgm_boss", terrainType: "boss", difficulty: 3, specialFeature: "boss_frog"),

        // ===== 世界3：火山地带 =====
        LevelConfig(levelNumber: 9, name: "Magma Edge", width: 6500, enemyCount: 14, itemCount: 20, timeLimit: 210,
                    backgroundMusic: "bgm_world3", terrainType: "volcano", difficulty: 3, specialFeature: "lava"),
        LevelConfig(levelNumber: 10, name: "Falling Abyss", width: 7000, enemyCount: 16, itemCount: 22, timeLimit: 210,
                    backgroundMusic: "bgm_world3", terrainType: "volcano", difficulty: 4, specialFeature: "vertical_fall"),
        LevelConfig(levelNumber: 11, name: "Molten Cavern", width: 7500, enemyCount: 18, itemCount: 25, timeLimit: 240,
                    backgroundMusic: "bgm_world3", terrainType: "underground", difficulty: 4, specialFeature: "lava_flow"),
        LevelConfig(levelNumber: 12, name: "Lava Dragon", width: 3000, enemyCount: 1, itemCount: 12, timeLimit: 180,
                    backgroundMusic: "bgm_boss", terrainType: "boss", difficulty: 4, specialFeature: "boss_lava"),

        // ===== 世界4：最终岛屿 =====
        LevelConfig(levelNumber: 13, name: "Storm Cliff", width: 7000, enemyCount: 14, itemCount: 22, timeLimit: 210,
                    backgroundMusic: "bgm_world4", terrainType: "cliff", difficulty: 3, specialFeature: "strong_wind"),
        LevelConfig(levelNumber: 14, name: "Ancient Ruins", width: 8000, enemyCount: 16, itemCount: 28, timeLimit: 240,
                    backgroundMusic: "bgm_world4", terrainType: "ruins", difficulty: 4, specialFeature: "traps"),
        LevelConfig(levelNumber: 15, name: "Sky Temple", width: 8500, enemyCount: 18, itemCount: 30, timeLimit: 270,
                    backgroundMusic: "bgm_world4", terrainType: "sky", difficulty: 4, specialFeature: "floating_platforms"),
        LevelConfig(levelNumber: 16, name: "Dark Dragon God", width: 3500, enemyCount: 1, itemCount: 15, timeLimit: 270,
                    backgroundMusic: "bgm_final_boss", terrainType: "boss", difficulty: 5, specialFeature: "boss_dark")
    ]

    // MARK: - 世界信息
    struct WorldInfo {
        let worldNumber: Int
        let name: String
        let startLevel: Int
        let endLevel: Int
    }

    let worlds: [WorldInfo] = [
        WorldInfo(worldNumber: 1, name: "Beginner's Island", startLevel: 1, endLevel: 4),
        WorldInfo(worldNumber: 2, name: "Tropical Jungle", startLevel: 5, endLevel: 8),
        WorldInfo(worldNumber: 3, name: "Volcanic Zone", startLevel: 9, endLevel: 12),
        WorldInfo(worldNumber: 4, name: "Final Island", startLevel: 13, endLevel: 16)
    ]

    // MARK: - 获取关卡配置
    func getLevelConfig(_ levelNumber: Int) -> LevelConfig? {
        guard levelNumber > 0 && levelNumber <= levelConfigs.count else { return nil }
        return levelConfigs[levelNumber - 1]
    }

    func getTotalLevels() -> Int {
        return levelConfigs.count
    }

    func getWorldForLevel(_ levelNumber: Int) -> WorldInfo? {
        return worlds.first { levelNumber >= $0.startLevel && levelNumber <= $0.endLevel }
    }

    // MARK: - 关卡数据生成（确定性）
    func generateLevelData(_ levelNumber: Int) -> LevelData {
        guard let config = getLevelConfig(levelNumber) else {
            return LevelData.empty()
        }

        // 优先使用确定性种子数据，保持关卡完全可复现
        if let seedData = LevelSeedStorage.getSpawnData(for: levelNumber) {
            return LevelData(
                levelNumber: config.levelNumber,
                name: config.name,
                width: config.width,
                timeLimit: config.timeLimit,
                backgroundMusic: config.backgroundMusic,
                terrainType: config.terrainType,
                difficulty: config.difficulty,
                specialFeature: config.specialFeature,
                enemies: seedData.enemies,
                items: seedData.items
            )
        }

        // 兜底：如果没有预生成数据（理论上不会走到这里），仍用随机生成
        var enemies: [EnemySpawnData] = []
        var items: [ItemSpawnData] = []

        for i in 0..<config.enemyCount {
            let x = CGFloat(i + 1) * (config.width / CGFloat(config.enemyCount + 1))
            let y = CGFloat.random(in: 100...300)
            let type = getEnemyType(for: i, terrain: config.terrainType)
            enemies.append(EnemySpawnData(x: x, y: y, type: type))
        }

        for i in 0..<config.itemCount {
            let x = CGFloat(i + 1) * (config.width / CGFloat(config.itemCount + 1))
            let y = CGFloat.random(in: 80...200)
            let type = getItemType(for: i, difficulty: config.difficulty)
            items.append(ItemSpawnData(x: x, y: y, type: type))
        }

        return LevelData(
            levelNumber: config.levelNumber,
            name: config.name,
            width: config.width,
            timeLimit: config.timeLimit,
            backgroundMusic: config.backgroundMusic,
            terrainType: config.terrainType,
            difficulty: config.difficulty,
            specialFeature: config.specialFeature,
            enemies: enemies,
            items: items
        )
    }

    // 根据关卡类型和难度获取敌人类型
    private func getEnemyType(for index: Int, terrain: String) -> String {
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
        return types[index % types.count]
    }

    // 根据难度获取物品类型
    private func getItemType(for index: Int, difficulty: Int) -> String {
        let easyItems = ["coin", "fruit", "health"]
        let mediumItems = ["coin", "fruit", "health", "powerup", "egg"]
        let hardItems = ["coin", "egg", "diamond", "powerup", "health"]

        let items = difficulty <= 2 ? easyItems : (difficulty <= 4 ? mediumItems : hardItems)
        return items[index % items.count]
    }
}

// MARK: - 关卡数据结构
struct LevelData {
    let levelNumber: Int
    let name: String
    let width: CGFloat
    let timeLimit: Int
    let backgroundMusic: String
    let terrainType: String
    let difficulty: Int
    let specialFeature: String
    let enemies: [EnemySpawnData]
    let items: [ItemSpawnData]

    static func createDefault() -> LevelData {
        return LevelData(
            levelNumber: 1, name: "Level 1", width: 3000, timeLimit: 60,
            backgroundMusic: "", terrainType: "grass", difficulty: 1,
            specialFeature: "none", enemies: [], items: []
        )
    }

    static func empty() -> LevelData {
        return LevelData(
            levelNumber: 0, name: "", width: 3000, timeLimit: 60,
            backgroundMusic: "", terrainType: "grass", difficulty: 1,
            specialFeature: "none", enemies: [], items: []
        )
    }
}

struct EnemySpawnData {
    let x: CGFloat
    let y: CGFloat
    let type: String
}

struct ItemSpawnData {
    let x: CGFloat
    let y: CGFloat
    let type: String
}