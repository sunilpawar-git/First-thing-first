import SwiftUI

class ScrollIndicatorViewModel: ObservableObject {
    @Published var scrollOffset: CGFloat = 0
    @Published var isTopIndicatorVisible: Bool = false
    @Published var isBottomIndicatorVisible: Bool = true
    
    private let hapticService: HapticServiceProtocol
    private let soundService: SoundServiceProtocol
    private var lastScrollOffset: CGFloat = 0
    private var lastHapticTime: Date = Date()
    
    init(
        hapticService: HapticServiceProtocol = HapticService(),
        soundService: SoundServiceProtocol = SoundService()
    ) {
        self.hapticService = hapticService
        self.soundService = soundService
    }
    
    func handleScroll(value: CGFloat, screenHeight: CGFloat) {
        let scrollDelta = abs(value - lastScrollOffset)
        let currentTime = Date()
        
        if currentTime.timeIntervalSince(lastHapticTime) > AppConstants.hapticInterval && 
           scrollDelta > AppConstants.scrollHapticThreshold {
            hapticService.trigger(.soft, intensity: min(scrollDelta / 50, 1.0))
            soundService.playSound(.scroll)
            lastHapticTime = currentTime
        }
        
        isTopIndicatorVisible = value < -50
        isBottomIndicatorVisible = value > -screenHeight * 0.8
        
        lastScrollOffset = scrollOffset
        scrollOffset = value
    }
} 