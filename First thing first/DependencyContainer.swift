import Foundation

class DependencyContainer {
    static let shared = DependencyContainer()
    
    let dataService: DataServiceProtocol
    
    private init() {
        self.dataService = DataService()
    }
} 