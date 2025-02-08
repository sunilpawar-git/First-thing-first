import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var scrollPlayer: AVAudioPlayer?
    private var selectPlayer: AVAudioPlayer?
    private var addTaskPlayer: AVAudioPlayer?
    
    private init() {
        setupSounds()
    }
    
    private func setupSounds() {
        // Setup scroll sound
        if let url = Bundle.main.url(forResource: "tick", withExtension: "wav") {
            scrollPlayer = try? AVAudioPlayer(contentsOf: url)
            scrollPlayer?.prepareToPlay()
            scrollPlayer?.volume = 0.3 // Lower volume for scroll
        }
        
        // Setup selection sound
        if let url = Bundle.main.url(forResource: "tick", withExtension: "wav") {
            selectPlayer = try? AVAudioPlayer(contentsOf: url)
            selectPlayer?.prepareToPlay()
            selectPlayer?.volume = 0.5
        }
        
        // Setup add task sound
        if let url = Bundle.main.url(forResource: "tick", withExtension: "wav") {
            addTaskPlayer = try? AVAudioPlayer(contentsOf: url)
            addTaskPlayer?.prepareToPlay()
            addTaskPlayer?.volume = 0.4
        }
    }
    
    func playScrollSound() {
        scrollPlayer?.currentTime = 0
        scrollPlayer?.play()
    }
    
    func playSelectSound() {
        selectPlayer?.currentTime = 0
        selectPlayer?.play()
    }
    
    func playAddTaskSound() {
        addTaskPlayer?.currentTime = 0
        addTaskPlayer?.play()
    }
} 