import Foundation
import SwiftData

@Model
public class Item {
    public var date: Date
    public var tasks: [String]
    
    public init(date: Date = Date(), tasks: [String] = []) {
        self.date = date
        self.tasks = tasks
    }
} 