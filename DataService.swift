import SwiftData
import Foundation

public class DataService: DataServiceProtocol {
    private let modelContext: ModelContext
    private var itemsDescriptor: FetchDescriptor<Item>
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.itemsDescriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\.date)])
    }
    
    public var items: [Item] {
        do {
            let fetchedItems = try modelContext.fetch(itemsDescriptor)
            return fetchedItems
        } catch {
            print("Error fetching items: \(error.localizedDescription)")
            return []
        }
    }
    
    public func addTask(_ task: String, for date: Date) {
        if let item = items.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            item.tasks.insert("- \(task)", at: 0)
            try? save()
        }
    }
    
    public func moveTask(_ task: String, from: Date, to: Date) {
        // Implementation
    }
    
    public func getTasks(for date: Date) -> [String] {
        items.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?.tasks ?? []
    }
    
    public func updateOrderedWeekItems() {
        // Implementation
    }
    
    public func insert(_ item: Item) {
        modelContext.insert(item)
    }
    
    public func save() throws {
        try modelContext.save()
    }
} 