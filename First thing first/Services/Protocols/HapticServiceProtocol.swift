import Foundation

public protocol HapticServiceProtocol {
    func trigger(_ style: HapticStyle, intensity: Double?)
}

public enum HapticStyle {
    case soft
    case medium
    case heavy
} 