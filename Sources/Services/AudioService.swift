import Foundation
import AVFoundation

class AudioService: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false
    
    enum Accent: Int {
        case american = 0  // 美音
        case british = 1   // 英音
    }
    
    /// 播放单词发音
    func playPronunciation(word: String, accent: Accent) {
        let urlString = "https://dict.youdao.com/dictvoice?type=\(accent.rawValue)&audio=\(word)"
        
        guard let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://dict.youdao.com/dictvoice?type=\(accent.rawValue)&audio=\(encodedWord)") else {
            print("Invalid URL for word: \(word)")
            return
        }
        
        // 停止之前的播放
        player?.pause()
        
        // 创建新的播放器
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        isPlaying = true
        
        // 监听播放完成
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
        }
        
        player?.play()
    }
    
    /// 停止播放
    func stop() {
        player?.pause()
        isPlaying = false
    }
}
