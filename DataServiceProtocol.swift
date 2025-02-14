import Foundation
import SwiftData

public protocol DataServiceProtocol {
    var items: [Item] { get }
    func addTask(_ task: String, for date: Date)
    func moveTask(_ task: String, from: Date, to: Date)
    func getTasks(for date: Date) -> [String]
    func updateOrderedWeekItems()
    func insert(_ item: Item)
    func save() throws
} 