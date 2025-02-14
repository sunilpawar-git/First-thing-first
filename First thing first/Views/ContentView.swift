//
//  ContentView.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI

// Making both structures public to ensure they're accessible
public struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel: TaskViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var keyboardHeight: CGFloat = 0
    
    public init(viewModel: TaskViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                mainContent(geometry)
            }
            .navigationTitle("First thing, first")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard)
            .onAppear {
                setupKeyboardNotifications()
            }
            .onDisappear {
                removeKeyboardNotifications()
            }
            #if swift(>=5.9)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .inactive {
                    handleScenePhaseChange(newPhase)
                }
            }
            #else
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    handleScenePhaseChange(newPhase)
                }
            }
            #endif
        }
    }
    
    // MARK: - Helper Views
    
    private func mainContent(_ geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            themeManager.currentTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header space
                        Color.clear
                            .frame(height: 20)
                        
                        // Main content with consistent spacing
                        LazyVStack(spacing: 10) { // Increased from 7 to 10 points for more visual separation
                            ForEach(viewModel.orderedWeekItems, id: \.date) { item in
                                let isSelected = Calendar.current.isDate(item.date, inSameDayAs: viewModel.selectedDate)
                                let isToday = Calendar.current.isDateInToday(item.date)
                                
                                dayTile(for: item, geometry: geometry)
                                    .id(item.date)
                                    .frame(
                                        maxWidth: geometry.size.width - 32,
                                        maxHeight: isSelected || (isToday && !isSelected) ? nil : 140,
                                        alignment: .top
                                    )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bottom padding
                        Color.clear
                            .frame(height: keyboardHeight + geometry.size.height/3)
                    }
                }
                .onChange(of: viewModel.selectedDate) { _, newDate in
                    withAnimation(.easeOut(duration: 0.3)) {
                        scrollProxy.scrollTo(newDate, anchor: .center)
                    }
                }
            }
        }
    }
    
    private func dayTile(for item: Item, geometry: GeometryProxy) -> some View {
        let isSelected = Calendar.current.isDate(item.date, inSameDayAs: viewModel.selectedDate)
        let isToday = Calendar.current.isDateInToday(item.date)
        
        return DayTileView(
            item: item,
            isSelected: isSelected,
            isToday: isToday,
            selectedDate: viewModel.selectedDate,
            newTask: isSelected ? $viewModel.newTask : .constant(""),
            onAddTask: isSelected ? viewModel.addTask : nil,
            orderedWeekItems: viewModel.orderedWeekItems,
            dataService: viewModel.dataService
        )
        .scaleEffect(isSelected || isToday ? 1.0 : 0.98)
        .animation(.spring(response: 0.3), value: isSelected)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.3)) {
                viewModel.selectDate(item.date)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        if phase == .inactive {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                         to: nil, 
                                         from: nil, 
                                         for: nil)
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            keyboardHeight = keyboardFrame.height
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView {
            ContentView(viewModel: PreviewContainer.taskViewModel)
        }
    }
}
