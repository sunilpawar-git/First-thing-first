//
//  WeeklyPlannerView.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

struct WeeklyPlannerView: View {
    @Query(sort: \Item.date) private var items: [Item]
    @State private var showingAddTaskSheet = false

    private var weeklyTasks: [Date: [Item]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let sevenDayInterval = DateInterval(start: today, duration: 7 * 24 * 60 * 60) // 7 days from today
        
        let tasksInSevenDays = items.filter { sevenDayInterval.contains($0.date) }
        
        let groupedTasks = Dictionary(grouping: tasksInSevenDays) { item in
            calendar.startOfDay(for: item.date)
        }
        
        return groupedTasks
    }
    
    private var orderedWeekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        return dates
    }

    static let dayAndDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE (dd MMM yyyy)"
        return formatter
    }()

    var body: some View {
        NavigationView {
            List {
                ForEach(orderedWeekDays, id: \.self) { date in
                    let tasksForDay = weeklyTasks[date] ?? []
                    Section(header: Text(date, formatter: Self.dayAndDateFormatter).font(.headline)) {
                        ForEach(tasksForDay) { item in
                            TaskTile(item: item)
                        }
                    }
                    .listRowSeparator(.hidden)
                    if date != orderedWeekDays.last {
                        Divider()
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle("Weekly, still Firsts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTaskSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskSheet) {
                AddTaskSheet()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
