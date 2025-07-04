//
//  TaskListView.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.date) private var items: [Item]
    
    @State private var showingAddTaskSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    TaskTile(item: item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("First Things First")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddTaskSheet) {
                AddTaskSheet()
            }
            .overlay(alignment: .bottomTrailing) {
                FloatingActionButton {
                    showingAddTaskSheet.toggle()
                }
                .padding()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
