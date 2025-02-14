import Foundation
import AVFoundation

public class SoundService: SoundServiceProtocol {
    private var scrollPlayer: AVAudioPlayer?
    private var selectPlayer: AVAudioPlayer?
    private var addTaskPlayer: AVAudioPlayer?
    
    public init() {
        setupSounds()
    }
    
    private func setupSounds() {
        if let url = Bundle.main.url(forResource: "tick", withExtension: "wav") {
            scrollPlayer = try? AVAudioPlayer(contentsOf: url)
            selectPlayer = try? AVAudioPlayer(contentsOf: url)
            addTaskPlayer = try? AVAudioPlayer(contentsOf: url)
            
            scrollPlayer?.prepareToPlay()
            selectPlayer?.prepareToPlay()
            addTaskPlayer?.prepareToPlay()
        }
    }
    
    public func playSound(_ type: SoundType) {
        switch type {
        case .scroll:
            scrollPlayer?.currentTime = 0
            scrollPlayer?.play()
        case .select:
            selectPlayer?.currentTime = 0
            selectPlayer?.play()
        case .addTask:
            addTaskPlayer?.currentTime = 0
            addTaskPlayer?.play()
        }
    }
} 