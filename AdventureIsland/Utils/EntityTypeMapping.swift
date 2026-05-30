import Foundation

/// 统一管理所有实体类型到资源文件名的映射
/// 避免 Enemy / Item / BossNode 各自重复定义 typeToImage 字典
struct EntityTypeMapping {

    // MARK: - 敌人类型 → 图片名
    static let enemy: [String: String] = [
        "dinosaur": "02_enemy_dinosaur",
        "raptor": "06_boss_raptor",
        "snail": "03_enemy_snail",
        "bee": "04_enemy_bee",
        "piranha": "05_enemy_piranha",
        "frog": "07_boss_frog",
        "lizard": "02_enemy_dinosaur",
        "snake": "02_enemy_dinosaur",
        "bat": "29_enemy_bat",
        "volcanic_bat": "29_enemy_bat",
        "skeleton": "31_enemy_skeleton",
        "fire_skeleton": "31_enemy_skeleton",
        "scorpion": "30_enemy_scorpion",
        "seagull": "04_enemy_bee",
        "fire_lizard": "08_boss_lava_dragon",
        "fire_beetle": "28_enemy_skull_fire",
        "magma_worm": "28_enemy_skull_fire",
        "magma_sprite": "28_enemy_skull_fire",
        "magma_ghost": "28_enemy_skull_fire",
        "magma_golem": "28_enemy_skull_fire",
        "storm_vulture": "29_enemy_bat",
        "lightning_lizard": "02_enemy_dinosaur",
        "guardian_statue": "09_boss_dark_dragon",
        "curse_ghost": "28_enemy_skull_fire",
        "ancient_beetle": "28_enemy_skull_fire",
        "sky_knight": "09_boss_dark_dragon",
        "guardian_angel": "07_boss_frog",
        "thunder_orb": "32_projectile_fireball",
        "worm": "28_enemy_skull_fire",
        "lava_dragon": "08_boss_lava_dragon",
        "dark_dragon": "09_boss_dark_dragon"
    ]

    // MARK: - 物品类型 → 图片名
    static let item: [String: String] = [
        "coin": "10_item_coin",
        "gold": "10_item_coin",
        "apple": "11_item_apple",
        "fruit": "11_item_apple",
        "banana": "12_item_banana",
        "grape": "17_item_grape",
        "egg": "13_item_egg",
        "heart": "14_item_heart",
        "health": "14_item_heart",
        "red_heart": "14_item_heart",
        "diamond": "15_item_diamond",
        "star": "16_item_star",
        "powerup": "16_item_star",
        "coconut": "11_item_apple",
        "crystal": "15_item_diamond"
    ]

    // MARK: - Boss类型 → 图片名
    static let boss: [String: String] = [
        "boss_raptor": "06_boss_raptor",
        "boss_frog": "07_boss_frog",
        "boss_lava": "08_boss_lava_dragon",
        "boss_dark": "09_boss_dark_dragon"
    ]
}
