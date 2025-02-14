import Foundation
import Combine
import SwiftUI

public class DataService: DataServiceProtocol, ObservableObject {
    @Published private(set) var itemsArray: [Item] = []
    private let defaults = UserDefaults.standard
    private let tasksKey = "savedTasks"
    
    // Task structure that can be encoded/decoded
    private struct TaskItem: Codable {
        let date: Date
        var tasks: [String]
    }
    
    public init() {
        // Load initial data without triggering updates
        let taskItems = getAllItems()
        itemsArray = taskItems.map { Item(date: $0.date, tasks: $0.tasks) }
        
        // Setup initial data if needed
        if itemsArray.isEmpty {
            let today = Date()
            let newItem = TaskItem(date: today, tasks: [])
            saveItem(newItem)
            loadItems()
        }
    }
    
    private func loadItems() {
        let taskItems = getAllItems()
        DispatchQueue.main.async { [weak self] in
            self?.itemsArray = taskItems.map { Item(date: $0.date, tasks: $0.tasks) }
        }
    }
    
    public var items: [Item] {
        itemsArray
    }
    
    private func getAllItems() -> [TaskItem] {
        guard let data = defaults.data(forKey: tasksKey),
              let items = try? JSONDecoder().decode([TaskItem].self, from: data) else {
            return []
        }
        return items
    }
    
    private func saveItems(_ items: [TaskItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            defaults.set(data, forKey: tasksKey)
            defaults.synchronize() // Force immediate save
            print("Items saved successfully") // Debug log
        } catch {
            print("Error saving items: \(error)") // Debug log
        }
    }
    
    private func saveItem(_ item: TaskItem) {
        var currentItems = getAllItems()
        if let index = currentItems.firstIndex(where: { isSameDay($0.date, item.date) }) {
            currentItems[index] = item
        } else {
            currentItems.append(item)
        }
        saveItems(currentItems)
    }
    
    public func addTask(_ task: String, for date: Date) {
        let cleanTask = task.trimmingCharacters(in: CharacterSet(charactersIn: "- "))
        
        // Batch updates to prevent multiple UI refreshes
        if let item = items.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            if !item.tasks.contains(cleanTask) {
                withAnimation {
                    item.addTask(cleanTask)
                    try? save()
                }
            }
        } else {
            let newItem = Item(date: date, tasks: [cleanTask])
            withAnimation {
                insert(newItem)
            }
        }
    }
    
    public func moveTask(_ task: String, from: Date, to: Date) {
        var currentItems = getAllItems()
        
        guard let fromIndex = currentItems.firstIndex(where: { isSameDay($0.date, from) }),
              let taskIndex = currentItems[fromIndex].tasks.firstIndex(of: task) else {
            return
        }
        
        // Remove from source
        currentItems[fromIndex].tasks.remove(at: taskIndex)
        
        // Add to destination
        if let toIndex = currentItems.firstIndex(where: { isSameDay($0.date, to) }) {
            currentItems[toIndex].tasks.insert(task, at: 0)
        } else {
            let newItem = TaskItem(date: to, tasks: [task])
            currentItems.append(newItem)
        }
        
        saveItems(currentItems)
    }
    
    public func getTasks(for date: Date) -> [String] {
        getAllItems()
            .first(where: { isSameDay($0.date, date) })?
            .tasks ?? []
    }
    
    public func updateOrderedWeekItems() {
        let calendar = Calendar.current
        let today = Date()
        var currentItems = getAllItems()
        var needsUpdate = false
        
        for dayOffset in 0...6 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }
            
            if !currentItems.contains(where: { isSameDay($0.date, date) }) {
                let newItem = TaskItem(date: date, tasks: [])
                currentItems.append(newItem)
                needsUpdate = true
            }
        }
        
        if needsUpdate {
            saveItems(currentItems)
            // Update UI on main thread
            DispatchQueue.main.async { [weak self] in
                self?.loadItems()
            }
        }
    }
    
    public func insert(_ item: Item) {
        let taskItem = TaskItem(date: item.date, tasks: item.tasks)
        saveItem(taskItem)
    }
    
    public func save() throws {
        // No-op as saves are immediate with UserDefaults
    }
    
    public func deleteTask(_ task: String, from date: Date) {
        if let item = items.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            item.removeTask(task)
            try? save()
        }
    }
    
    public func moveTaskToNextDay(_ task: String, from date: Date) {
        if let currentItem = items.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            currentItem.removeTask(task)
            
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                if let nextItem = items.first(where: { Calendar.current.isDate($0.date, inSameDayAs: nextDate) }) {
                    nextItem.addTask(task)
                } else {
                    let newItem = Item(date: nextDate, tasks: [task])
                    insert(newItem)
                }
            }
            
            try? save()
        }
    }
    
    public func deleteItem(for date: Date) {
        var currentItems = getAllItems()
        currentItems.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        saveItems(currentItems)
        loadItems() // Refresh the UI
    }
    
    // MARK: - Helper Methods
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
} 