import SwiftUI

class DayTileViewModel: ObservableObject {
    @Published var item: Item
    @Published var isSelected: Bool
    @Published var distanceFromSelected: Int
    
    private let hapticService: HapticServiceProtocol
    private let soundService: SoundServiceProtocol
    
    init(
        item: Item,
        isSelected: Bool = false,
        distanceFromSelected: Int = 0,
        hapticService: HapticServiceProtocol = HapticService(),
        soundService: SoundServiceProtocol = SoundService()
    ) {
        self.item = item
        self.isSelected = isSelected
        self.distanceFromSelected = distanceFromSelected
        self.hapticService = hapticService
        self.soundService = soundService
    }
    
    func moveTaskToNextDay(task: String, in orderedWeekItems: [Item]) {
        if let currentIndex = orderedWeekItems.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: item.date) }),
           currentIndex < orderedWeekItems.count - 1 {
            let nextDayItem = orderedWeekItems[currentIndex + 1]
            
            if let taskIndex = item.tasks.firstIndex(of: task) {
                item.tasks.remove(at: taskIndex)
                nextDayItem.tasks.insert(task, at: 0)
                hapticService.trigger(.medium, intensity: 0.6)
                soundService.playSound(.addTask)
            }
        }
    }
} 