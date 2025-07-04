//
//  TaskTile.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

struct TaskTile: View {
    @Bindable var item: Item
    @State private var showingEditTaskSheet = false
    
    var isOverdueAndNotCompleted: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let itemDate = calendar.startOfDay(for: item.date)
        return itemDate <= today && !item.isCompleted
    }

    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(item.isCompleted ? .green : .primary)
                .onTapGesture {
                    item.isCompleted.toggle()
                }
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(isOverdueAndNotCompleted ? .red : .primary)
                Text(item.date, formatter: Self.fullDateFormatter)
                    .font(.caption)
                    .foregroundColor(isOverdueAndNotCompleted ? .red : .secondary)
            }
            .onTapGesture {
                showingEditTaskSheet.toggle()
            }
        }
        .sheet(isPresented: $showingEditTaskSheet) {
            EditTaskSheet(item: item)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
