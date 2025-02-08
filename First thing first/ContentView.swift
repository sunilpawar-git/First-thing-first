//
//  ContentView.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

// Making both structures public to ensure they're accessible
public struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.date) private var items: [Item]
    @State private var newTask: String = ""
    @State private var selectedDate: Date = Date() // Track selected date
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var lastHapticTime: Date = Date()
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .soft)  // Changed to soft for smoother feel
    private let hapticInterval: TimeInterval = 0.15  // Minimum time between haptics
    
    public init() {} // Add public initializer
    
    private var orderedWeekItems: [Item] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = 2 - weekday
        let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)!
        
        return (0...6).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: monday)!
            if let existingItem = items.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                return existingItem
            }
            let newItem = Item(date: date)
            modelContext.insert(newItem)
            return newItem
        }
    }
    
    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [Color(hex: "F5F5F5"), Color(hex: "FFFFFF")],
                        startPoint: .top,
                        endPoint: .bottom
                    ).ignoresSafeArea()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack {
                            // Scroll position tracker
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: proxy.frame(in: .named("scroll")).minY
                                )
                            }
                            
                            VStack(spacing: -geometry.size.height * 0.45) {
                                // Using regular order but adjusting z-index for proper stacking
                                ForEach(orderedWeekItems, id: \.date) { item in
                                    let isSelected = Calendar.current.isDate(item.date, inSameDayAs: selectedDate)
                                    
                                    DayTileView(
                                        item: item,
                                        isSelected: isSelected,
                                        distanceFromSelected: calculateDistance(from: selectedDate, to: item.date),
                                        newTask: isSelected ? $newTask : .constant(""),
                                        onAddTask: isSelected ? addTask : nil,
                                        orderedWeekItems: orderedWeekItems
                                    )
                                    .frame(
                                        height: isSelected ? 
                                            geometry.size.height * 0.72 :  // 20% more than 0.6 for selected tile
                                            geometry.size.height * 0.6     // Normal height for other tiles
                                    )
                                    .offset(y: calculateOffset(isSelected: isSelected, distance: calculateDistance(from: selectedDate, to: item.date), geometry: geometry))
                                    // Fixed z-index calculation to maintain proper order
                                    .zIndex(isSelected ? 100 : -Double(calculateDistance(from: selectedDate, to: item.date)))
                                    .onTapGesture {
                                        hapticFeedback.impactOccurred()
                                        SoundManager.shared.playSelectSound()
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedDate = item.date
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, geometry.size.height * 0.15)
                            .padding(.bottom, geometry.size.height * 0.4)
                            
                            // Updated Scroll indicators
                            ZStack {
                                VStack {
                                    // Top scroll indicator (shows when scrolled down)
                                    if scrollOffset < -50 {
                                        ScrollIndicator(isAtTop: false, isAtBottom: true)
                                            .padding(.top, geometry.size.height * 0.05)
                                    }
                                    
                                    Spacer()
                                }
                                
                                VStack {
                                    Spacer()
                                    // Bottom scroll indicator (always visible at start)
                                    ScrollIndicator(isAtTop: true, isAtBottom: false)
                                        .padding(.bottom, geometry.size.height * 0.05)
                                        .opacity(scrollOffset < -geometry.size.height * 0.8 ? 0 : 1)
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: scrollOffset)
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        // Calculate scroll velocity
                        let scrollDelta = abs(value - lastScrollOffset)
                        let currentTime = Date()
                        
                        // Only trigger haptic and sound if enough time has passed and there's significant movement
                        if currentTime.timeIntervalSince(lastHapticTime) > hapticInterval && scrollDelta > 5 {
                            hapticFeedback.impactOccurred(intensity: min(scrollDelta / 50, 1.0))
                            SoundManager.shared.playScrollSound()
                            lastHapticTime = currentTime
                        }
                        
                        lastScrollOffset = scrollOffset
                        scrollOffset = value
                    }
                }
            }
            .navigationTitle("First thing, first")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func calculateDistance(from date1: Date, to date2: Date) -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: date1, to: date2).day ?? 0
        return abs(days)
    }
    
    private func calculateOffset(isSelected: Bool, distance: Int, geometry: GeometryProxy) -> CGFloat {
        if isSelected {
            return 0
        }
        let baseOffset = geometry.size.height * 0.05
        let distanceOffset = CGFloat(distance) * (geometry.size.height * 0.02)
        return baseOffset + distanceOffset
    }
    
    private func addTask() {
        guard !newTask.isEmpty else { return }
        withAnimation {
            if let selectedItem = orderedWeekItems.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                selectedItem.tasks.insert("- \(newTask)", at: 0)  // Insert at beginning instead of append
                newTask = ""
                try? modelContext.save()
                
                // Play sound and haptic for task addition
                hapticFeedback.impactOccurred(intensity: 0.6)
                SoundManager.shared.playAddTaskSound()
            }
        }
    }
}

// Update ScrollIndicator to be context-aware
struct ScrollIndicator: View {
    @State private var offsetY: CGFloat = 0
    let isAtTop: Bool
    let isAtBottom: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if !isAtBottom {
                VStack(spacing: 4) {
                    Text("Scroll Up")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                    Image(systemName: "chevron.up")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                }
                .offset(y: -offsetY)
            }
            
            if !isAtTop {
                VStack(spacing: 4) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                    Text("Scroll Down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                }
                .offset(y: offsetY)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                offsetY = 8
            }
        }
    }
}

// Update DayTileView struct definition
public struct DayTileView: View {
    let item: Item
    let isSelected: Bool
    let distanceFromSelected: Int
    @Binding var newTask: String
    let onAddTask: (() -> Void)?
    let orderedWeekItems: [Item]
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    public init(item: Item, 
               isSelected: Bool, 
               distanceFromSelected: Int, 
               newTask: Binding<String>, 
               onAddTask: (() -> Void)?,
               orderedWeekItems: [Item]
    ) {
        self.item = item
        self.isSelected = isSelected
        self.distanceFromSelected = distanceFromSelected
        self._newTask = newTask
        self.onAddTask = onAddTask
        self.orderedWeekItems = orderedWeekItems
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd-MM-yyyy"  // Shows day name and date
        return formatter
    }()
    
    private var tileColor: Color {
        if isSelected {
            return .white
        } else {
            let baseOpacity: Double = 1.0
            let opacityDelta = min(Double(distanceFromSelected) * 0.15, 0.5)  // Increased opacity delta
            return Color(hex: "E5E5E5").opacity(baseOpacity - opacityDelta)  // Darker base color
        }
    }
    
    public var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .leading, spacing: 16) {
                // Day header (only show when selected)
                if isSelected {
                    Text(dateFormatter.string(from: item.date).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .transition(.opacity)
                        .lineLimit(1)
                    
                    // Task input (only when selected)
                    HStack(spacing: 12) {
                        TextField("Add task", text: $newTask)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color(hex: "F5F5F5"))
                            .cornerRadius(8)
                        
                        Button(action: { onAddTask?() }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.8))
                                .clipShape(Circle())
                        }
                    }
                    
                    // Tasks list (only when selected)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(item.tasks.enumerated()), id: \.element) { index, task in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(task)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 4)
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            moveTaskToNextDay(task: task)
                                        } label: {
                                            Label("Tomorrow", systemImage: "arrow.right")
                                        }
                                        .tint(.blue)
                                    }
                                
                                if index < item.tasks.count - 1 {
                                    Divider()
                                        .background(Color.gray.opacity(0.2))
                                        .padding(.horizontal, 4)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
            
            // Day indicators (only when not selected)
            if !isSelected {
                VStack {
                    // Always show day name at top when not selected
                    Text(dateFormatter.string(from: item.date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.25))  // Reduced opacity
                        .padding(.top, 20)
                        .transition(.opacity)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Always show day name at bottom when not selected
                    Text(dateFormatter.string(from: item.date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.25))  // Reduced opacity
                        .padding(.bottom, 20)
                        .transition(.opacity)
                        .lineLimit(1)
                }
                .opacity(abs(Double(distanceFromSelected)) * 0.5)  // Increased opacity effect
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            ZStack {
                // Bottom shadow for depth
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.05))
                    .offset(y: 4)
                    .blur(radius: 4)
                
                // Main tile
                RoundedRectangle(cornerRadius: 30)
                    .fill(tileColor)
                
                // More prominent outline
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        Color.black.opacity(isSelected ? 0.15 : 0.08),
                        lineWidth: 0.8
                    )
                
                // Inner highlight for depth
                RoundedRectangle(cornerRadius: 29)
                    .stroke(
                        Color.white,
                        lineWidth: 1
                    )
                    .blendMode(.overlay)
                    .padding(1)
                
                // Subtle gradient overlay for depth
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.overlay)
            }
        )
        .shadow(
            color: Color.black.opacity(isSelected ? 0.15 : 0.08),
            radius: isSelected ? 25 : 15,
            x: 0,
            y: isSelected ? 12 : 6
        )
        .rotation3DEffect(
            .degrees(isSelected ? 0 : 6),
            axis: (x: 1, y: 0, z: 0),
            anchor: .top
        )
        .opacity(isSelected ? 1.0 : 1.0 - Double(distanceFromSelected) * 0.1)
        .animation(
            .spring(response: 0.3, dampingFraction: 0.8), 
            value: isSelected
        )
        .animation(
            .easeInOut(duration: 0.2), 
            value: distanceFromSelected
        )
    }
    
    private func moveTaskToNextDay(task: String) {
        if let currentIndex = orderedWeekItems.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: item.date) }),
           currentIndex < orderedWeekItems.count - 1 {
            let nextDayItem = orderedWeekItems[currentIndex + 1]
            
            if let taskIndex = item.tasks.firstIndex(of: task) {
        withAnimation {
                    item.tasks.remove(at: taskIndex)
                    // Insert at beginning of next day's tasks
                    nextDayItem.tasks.insert(task, at: 0)
                    
                    // Play feedback
                    hapticFeedback.impactOccurred(intensity: 0.6)
                    SoundManager.shared.playAddTaskSound()
                }
            }
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Add preference key for scroll tracking
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
