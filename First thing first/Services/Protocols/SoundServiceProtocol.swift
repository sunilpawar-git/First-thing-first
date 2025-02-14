import Foundation

public protocol SoundServiceProtocol {
    func playSound(_ type: SoundType)
}

public enum SoundType {
    case scroll
    case select
    case addTask
} 