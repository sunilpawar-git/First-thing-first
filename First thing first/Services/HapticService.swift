import UIKit

public class HapticService: HapticServiceProtocol {
    public init() {}
    
    public func trigger(_ style: HapticStyle, intensity: Double? = nil) {
        let generator: UIImpactFeedbackGenerator
        
        switch style {
        case .soft:
            generator = UIImpactFeedbackGenerator(style: .soft)
        case .medium:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            generator = UIImpactFeedbackGenerator(style: .heavy)
        }
        
        if let intensity = intensity {
            generator.impactOccurred(intensity: intensity)
        } else {
            generator.impactOccurred()
        }
    }
} 