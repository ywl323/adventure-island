import Foundation

struct LevelSeedStorage {
    struct LevelSpawnData {
        let enemies: [EnemySpawnData]
        let items: [ItemSpawnData]
    }

    private static let seedData: [Int: LevelSpawnData] = generateAllSeeds()

    static func getSpawnData(for levelNumber: Int) -> LevelSpawnData? {
        return seedData[levelNumber]
    }

    private static func generateAllSeeds() -> [Int: LevelSpawnData] {
        var result: [Int: LevelSpawnData] = [:]

        for levelNum in 1...16 {
            let config = LevelManager.shared.getLevelConfig(levelNum)
            let terrain = config?.terrainType ?? "grass"
            let eCount = config?.enemyCount ?? 3
            let iCount = config?.itemCount ?? 10
            let levelWidth = config?.width ?? 3000
            let diff = config?.difficulty ?? 1

            var enemySpawns: [EnemySpawnData] = []
            for idx in 0..<eCount {
                let posX = CGFloat(idx + 1) * (levelWidth / CGFloat(eCount + 1))
                let posY = CGFloat(150 + (idx * 37 % 150))
                let enemyKind = terrainEnemyTypeSimple(terrain: terrain, index: idx)
                enemySpawns.append(EnemySpawnData(x: posX, y: posY, type: enemyKind))
            }

            var itemSpawns: [ItemSpawnData] = []
            for idx in 0..<iCount {
                let posX = CGFloat(idx + 1) * (levelWidth / CGFloat(iCount + 1))
                let posY = CGFloat(100 + (idx * 47 % 100))
                let itemKind = difficultyItemTypeSimple(difficulty: diff, index: idx)
                itemSpawns.append(ItemSpawnData(x: posX, y: posY, type: itemKind))
            }

            result[levelNum] = LevelSpawnData(enemies: enemySpawns, items: itemSpawns)
        }

        return result
    }

    private static func terrainEnemyTypeSimple(terrain: String, index: Int) -> String {
        let allTypes = ["dinosaur", "snail", "seagull", "bee", "lizard",
                        "piranha", "bat", "skeleton", "scorpion",
                        "fire_lizard", "sky_knight", "storm_vulture"]
        let idx = index % allTypes.count
        return allTypes[idx]
    }

    private static func difficultyItemTypeSimple(difficulty: Int, index: Int) -> String {
        let items = ["coin", "fruit", "health", "powerup", "egg"]
        let idx = index % items.count
        return items[idx]
    }
}
