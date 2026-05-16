import AVFoundation
import SpriteKit

class AudioManager {

    // MARK: - 单例
    static let shared = AudioManager()
    private init() {}

    // MARK: - 播放器
    private var bgmPlayer: AVAudioPlayer?
    private var sePlayers: [String: AVAudioPlayer] = [:]

    // MARK: - 音量
    var bgmVolume: Float = 0.5
    var seVolume: Float = 0.5

    // MARK: - BGM 加载和播放

    func loadBGM(_ name: String, ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("AudioManager: BGM 文件未找到 - \(name).\(ext)")
            return
        }
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1  // 循环播放
            bgmPlayer?.volume = bgmVolume
            bgmPlayer?.prepareToPlay()
        } catch {
            print("AudioManager: BGM 加载失败 - \(error)")
        }
    }

    func playBGM() {
        bgmPlayer?.play()
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }

    func pauseBGM() {
        bgmPlayer?.pause()
    }

    func resumeBGM() {
        bgmPlayer?.play()
    }

    // MARK: - SE 加载和播放

    func loadSE(_ name: String, ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("AudioManager: SE 文件未找到 - \(name).\(ext)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = seVolume
            player.prepareToPlay()
            sePlayers[name] = player
        } catch {
            print("AudioManager: SE 加载失败 - \(error)")
        }
    }

    func playSE(_ name: String) {
        if let player = sePlayers[name] {
            player.currentTime = 0
            player.play()
        } else {
            // 尝试动态加载
            loadSE(name)
            sePlayers[name]?.play()
        }
    }

    // MARK: - 音量控制

    func setBGMVolume(_ volume: Float) {
        bgmVolume = max(0, min(1, volume))
        bgmPlayer?.volume = bgmVolume
    }

    func setSEVolume(_ volume: Float) {
        seVolume = max(0, min(1, volume))
    }

    // MARK: - 游戏事件音效快捷方法

    func playJump() { playSE("se_jump") }
    func playCoin() { playSE("se_coin") }
    func playPowerUp() { playSE("se_powerup") }
    func playHurt() { playSE("se_hurt") }
    func playEnemyDeath() { playSE("se_enemy_death") }
    func playBossHit() { playSE("se_boss_hit") }
    func playLevelComplete() { playSE("se_level_complete") }
    func playButton() { playSE("se_button") }
    func playGameOver() { playSE("se_game_over") }

    // MARK: - 根据关卡加载背景音乐

    func loadBGMForLevel(_ levelNumber: Int) {
        let bgmName: String
        switch levelNumber {
        case 1...4:   bgmName = "bgm_world1"
        case 5...8:   bgmName = "bgm_world2"
        case 9...12:  bgmName = "bgm_world3"
        case 13...15: bgmName = "bgm_world4"
        case 16:      bgmName = "bgm_final_boss"
        default:      bgmName = "bgm_world1"
        }
        loadBGM(bgmName)
    }

    // MARK: - 批量预加载常用音效

    func preloadCommonSounds() {
        let commonSE = [
            "se_jump", "se_coin", "se_powerup", "se_hurt",
            "se_enemy_death", "se_boss_hit", "se_level_complete",
            "se_button", "se_game_over"
        ]
        preloadSounds(commonSE)
    }

    // MARK: - 清理

    func cleanup() {
        bgmPlayer?.stop()
        bgmPlayer = nil
        sePlayers.removeAll()
    }
}
