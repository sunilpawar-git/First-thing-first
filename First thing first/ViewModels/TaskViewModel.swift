import SwiftUI
import SwiftData
import Foundation

public class TaskViewModel: ObservableObject {
    // MARK: - Dependencies
    let dataService: any DataServiceProtocol
    private let hapticService: HapticServiceProtocol
    private let soundService: SoundServiceProtocol
    
    // MARK: - Published Properties
    @Published public var orderedWeekItems: [Item] = []
    @Published public var selectedDate: Date = Date()
    @Published public var newTask: String = ""
    @Published public var scrollOffset: CGFloat = 0
    @Published var tasks: [String] = []
    
    // MARK: - Private Properties
    private var lastScrollOffset: CGFloat = 0
    private var lastHapticTime: Date = Date()
    private let hapticInterval: TimeInterval = 0.15
    private var dateCheckTimer: Timer?
    
    // MARK: - Initialization
    public init(
        dataService: any DataServiceProtocol,
        hapticService: HapticServiceProtocol = HapticService(),
        soundService: SoundServiceProtocol = SoundService()
    ) {
        self.dataService = dataService
        self.hapticService = hapticService
        self.soundService = soundService
        updateOrderedWeekItems()
        setupDateChangeCheck()
    }
    
    // MARK: - Public Methods
    func addTask() {
        guard !newTask.isEmpty else { return }
        
        // Store task text
        let taskText = newTask
        
        // Clear input without affecting keyboard
        DispatchQueue.main.async { [weak self] in
            // Use the main queue to ensure proper text input handling
            self?.newTask = ""
        }
        
        // Add task and trigger feedback
        withTransaction(Transaction(animation: nil)) {
            dataService.addTask(taskText, for: selectedDate)
            updateOrderedWeekItems()
            
            // Trigger feedback
            hapticService.trigger(.medium, intensity: 0.6)
            soundService.playSound(.addTask)
        }
    }
    
    func handleScroll(value: CGFloat) {
        let scrollDelta = abs(value - lastScrollOffset)
        let currentTime = Date()
        
        if currentTime.timeIntervalSince(lastHapticTime) > hapticInterval && scrollDelta > 5 {
            hapticService.trigger(.soft, intensity: min(scrollDelta / 50, 1.0))
            soundService.playSound(.scroll)
            lastHapticTime = currentTime
        }
        
        lastScrollOffset = scrollOffset
        scrollOffset = value
    }
    
    func updateOrderedWeekItems() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Normalize today's date
        
        dataService.updateOrderedWeekItems() // Update data service first
        
        // Then update the view model's items for the week
        orderedWeekItems = (0...6).map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                return Item(date: today)
            }
            
            if let existingItem = dataService.items.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                print("Found existing item for \(date): \(existingItem.tasks)") // Debug log
                return existingItem
            }
            
            let newItem = Item(date: date)
            dataService.insert(newItem)
            return newItem
        }
    }
    
    func moveTask(_ task: String, from sourceItem: Item, to targetItem: Item) {
        if let taskIndex = sourceItem.tasks.firstIndex(of: task) {
            sourceItem.tasks.remove(at: taskIndex)
            targetItem.tasks.insert(task, at: 0)
            try? dataService.save()
        }
    }
    
    func calculateDistance(from date1: Date, to date2: Date) -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: date1, to: date2).day ?? 0
        return abs(days)
    }
    
    func calculateOffset(isSelected: Bool, distance: Int, geometry: GeometryProxy) -> CGFloat {
        if isSelected {
            return 0
        }
        let baseOffset = geometry.size.height * 0.05
        let distanceOffset = CGFloat(distance) * (geometry.size.height * 0.03)
        return baseOffset + distanceOffset
    }
    
    func selectDate(_ date: Date) {
        // Dismiss keyboard only when changing dates
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                      to: nil, 
                                      from: nil, 
                                      for: nil)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if (Calendar.current.isDateInToday(date) && !Calendar.current.isDate(selectedDate, inSameDayAs: date)) ||
               Calendar.current.isDate(selectedDate, inSameDayAs: date) {
                selectedDate = Date()
            } else {
                selectedDate = date
            }
        }
    }
    
    public func checkForDateChange() {
        let calendar = Calendar.current
        let now = Date()
        
        // If we've crossed midnight
        if !calendar.isDateInToday(selectedDate) {
            handleDayChange(now)
        }
    }
    
    private func setupDateChangeCheck() {
        // Check every minute for date changes
        dateCheckTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkForDateChange()
        }
    }
    
    private func handleDayChange(_ newDate: Date) {
        // 1. Get yesterday's date
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: newDate) else { return }
        
        // 2. Find and migrate incomplete tasks
        if let yesterdayItem = orderedWeekItems.first(where: { calendar.isDate($0.date, inSameDayAs: yesterday) }) {
            // Migrate tasks to today
            for task in yesterdayItem.tasks {
                dataService.moveTaskToNextDay(task, from: yesterday)
            }
            
            // Remove yesterday's item
            dataService.deleteItem(for: yesterday)
        }
        
        // 3. Update the view
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = newDate
            updateOrderedWeekItems()
        }
    }
} 