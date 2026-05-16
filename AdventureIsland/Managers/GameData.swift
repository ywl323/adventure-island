import Foundation

class GameData {
    static let shared = GameData()

    // MARK: - Keys
    private let highScoreKey = "adventure_island_high_score"
    private let highestUnlockedLevelKey = "adventure_island_highest_unlocked_level"
    private let completedLevelsKey = "adventure_island_completed_levels"

    private init() {}

    // MARK: - High Score
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }

    func updateHighScore(_ score: Int) {
        if score > highScore {
            highScore = score
            print("🏆 New high score: \(score)")
        }
    }

    // MARK: - Level Progress
    var highestUnlockedLevel: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: highestUnlockedLevelKey)
            return val > 0 ? val : 1  // Default to level 1
        }
        set {
            if newValue > highestUnlockedLevel {
                UserDefaults.standard.set(newValue, forKey: highestUnlockedLevelKey)
                print("🔓 Unlocked level: \(newValue)")
            }
        }
    }

    // MARK: - Completed Levels
    func isLevelCompleted(_ level: Int) -> Bool {
        let completed = completedLevels
        return completed.contains(level)
    }

    func markLevelCompleted(_ level: Int) {
        var completed = completedLevels
        if !completed.contains(level) {
            completed.append(level)
            UserDefaults.standard.set(completed, forKey: completedLevelsKey)
            print("✅ Level \(level) marked as completed")
        }
    }

    var completedLevels: [Int] {
        UserDefaults.standard.array(forKey: completedLevelsKey) as? [Int] ?? []
    }

    // MARK: - Unlock Next Level
    func unlockNextLevel(after level: Int) {
        let nextLevel = level + 1
        if nextLevel <= 16 {  // Total 16 levels
            highestUnlockedLevel = nextLevel
        }
    }

    // MARK: - Reset Progress
    func resetAllProgress() {
        highScore = 0
        highestUnlockedLevel = 1
        UserDefaults.standard.removeObject(forKey: completedLevelsKey)
        print("🗑️ All progress reset")
    }
}