import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme = .light
    
    static let shared = ThemeManager()
    private init() {}
    
    enum Theme {
        case light
        case dark
        
        var backgroundColor: LinearGradient {
            switch self {
            case .light:
                return LinearGradient(
                    colors: [Color(hex: "F5F5F5"), Color(hex: "FFFFFF")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .dark:
                return LinearGradient(
                    colors: [Color(hex: "1A1A1A"), Color(hex: "2D2D2D")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        
        var tileColor: Color {
            switch self {
            case .light: return .white
            case .dark: return Color(hex: "2D2D2D")
            }
        }
        
        var textColor: Color {
            switch self {
            case .light: return .black
            case .dark: return .white
            }
        }
        
        var secondaryTextColor: Color {
            switch self {
            case .light: return .black.opacity(0.4)
            case .dark: return .white.opacity(0.4)
            }
        }
    }
} 