//
//  ContentView.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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

struct TaskTile: View {
    @Bindable var item: Item
    
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
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AddTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var date = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("New Task")
                    .font(.headline)
                    .padding(.top)

                HStack {
                    TextField("What do you need to do?", text: $title)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: addTask) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title)
                            .foregroundColor(title.isEmpty ? .gray.opacity(0.5) : .blue)
                    }
                    .disabled(title.isEmpty)
                }
                .padding(.horizontal)

                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)

                Spacer()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func addTask() {
        print("addTask called. Title: \(title)") // Debug print
        guard !title.isEmpty else { 
            print("Title is empty, not adding task.") // Debug print
            return 
        }
        let newItem = Item(title: title, date: date)
        modelContext.insert(newItem)
        
        // Haptic feedback
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()
        
        dismiss()
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}