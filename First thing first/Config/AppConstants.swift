import SwiftUI

enum AppConstants {
    // Layout
    static let tilePadding: CGFloat = 24
    static let tileCornerRadius: CGFloat = 30
    static let selectedTileScale: CGFloat = 0.72
    static let normalTileScale: CGFloat = 0.6
    
    // Animation
    static let springResponse: Double = 0.3
    static let springDamping: Double = 0.8
    static let fadeAnimationDuration: Double = 0.2
    
    // Haptics
    static let scrollHapticThreshold: CGFloat = 5
    static let hapticInterval: TimeInterval = 0.15
    static let taskAddHapticIntensity: Double = 0.6
    
    // UI
    static let tileOpacityDeltaMultiplier: Double = 0.15
    static let maxTileOpacityDelta: Double = 0.5
    static let nonSelectedTileRotation: Double = 6
} 