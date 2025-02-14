import SwiftUI
import Foundation

@main
struct FirstThingFirstApp: App {
    @StateObject private var dataService = DataService()
    @StateObject private var viewModel: TaskViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let dataService = DataService()
        _dataService = StateObject(wrappedValue: dataService)
        _viewModel = StateObject(wrappedValue: TaskViewModel(dataService: dataService))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environmentObject(dataService)
                .environmentObject(themeManager)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // Check for date changes when app becomes active
                        viewModel.checkForDateChange()
                    }
                }
        }
    }
} 