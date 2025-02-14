import SwiftData
import Foundation

@Model
public class Item {
    public var date: Date
    public var tasks: [String]
    
    public init(date: Date = Date(), tasks: [String] = []) {
        self.date = date
        self.tasks = tasks
    }
}

// Helper extension to work with tasks
extension Item {
    func addTask(_ task: String) {
        tasks.insert(task, at: 0)
    }
    
    func removeTask(_ task: String) {
        tasks.removeAll { $0 == task }
    }
} 