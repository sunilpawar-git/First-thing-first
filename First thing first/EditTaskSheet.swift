//
//  EditTaskSheet.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

struct EditTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $item.title)
                DatePicker("Date", selection: $item.date, displayedComponents: .date)
                Toggle("Completed", isOn: $item.isCompleted)
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
