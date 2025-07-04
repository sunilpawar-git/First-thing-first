
//
//  AddTaskSheet.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

struct AddTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var date = Date()
    
    @FocusState private var isTitleFieldFocused: Bool // New focus state
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("New Task")
                    .font(.headline)
                    .padding(.top)

                HStack {
                    TextField("What do you need to do?", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(addTask)
                        .focused($isTitleFieldFocused) // Apply focus state
                    
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
        .onAppear { // Set focus when the sheet appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Small delay for animation
                isTitleFieldFocused = true
            }
        }
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
        
        SoundManager.shared.playAddTaskSound() // Add tick sound
        
        dismiss()
    }
}
