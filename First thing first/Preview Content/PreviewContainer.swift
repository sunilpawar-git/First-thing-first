import SwiftUI

struct PreviewContainer {
    // Services
    static let dataService = DataService()
    static let hapticService = HapticService()
    static let soundService = SoundService()
    static let themeManager = ThemeManager.shared
    
    // View Model with all required services
    static let taskViewModel = TaskViewModel(
        dataService: dataService,
        hapticService: hapticService,
        soundService: soundService
    )
    
    // Sample data
    static func setupSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Add sample tasks for the week
        for dayOffset in 0...6 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            dataService.addTask("Sample Task \(dayOffset + 1)", for: date)
        }
    }
    
    // Preview helper
    static var preview: some View {
        setupSampleData() // Initialize sample data
        return ContentView(viewModel: taskViewModel)
            .environmentObject(dataService)
            .environmentObject(themeManager)
    }
} 