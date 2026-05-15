import Foundation

class GameData {
    static let shared = GameData()

    private let highScoreKey = "adventure_island_high_score"

    private init() {}

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
}