import SwiftUI
import SwiftData
import UIKit // For UIImpactFeedbackGenerator

public struct DayTileView: View {
    let item: Item
    let isSelected: Bool
    let isToday: Bool
    let selectedDate: Date
    @Binding var newTask: String
    let onAddTask: (() -> Void)?
    let orderedWeekItems: [Item]
    @FocusState private var isTextFieldFocused: Bool
    let dataService: any DataServiceProtocol
    
    // Add a namespace for animation control
    @Namespace private var animation
    
    public init(
        item: Item,
        isSelected: Bool,
        isToday: Bool,
        selectedDate: Date,
        newTask: Binding<String>,
        onAddTask: (() -> Void)?,
        orderedWeekItems: [Item],
        dataService: any DataServiceProtocol
    ) {
        self.item = item
        self.isSelected = isSelected
        self.isToday = isToday
        self.selectedDate = selectedDate
        self._newTask = newTask
        self.onAddTask = onAddTask
        self.orderedWeekItems = orderedWeekItems
        self.dataService = dataService
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd-MM-yyyy"
        return formatter
    }()
    
    private var tileBackgroundColor: Color {
        if isToday {
            return Color.white // Pearl white for today
        }
        
        // Break down the distance calculation
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day], from: Date(), to: item.date)
        let distance = dateComponents.day ?? 0
        
        // Calculate grey shade
        let baseGrey: Double = 0.95
        let adjustment = abs(Double(distance)) * 0.05
        let greyAdjustment = min(adjustment, 0.3)
        
        return Color(white: baseGrey - greyAdjustment)
    }
    
    // Add these helper functions
    private func handleDelete(_ task: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            dataService.deleteTask(task, from: item.date)
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    private func handleMoveToNextDay(_ task: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            dataService.moveTaskToNextDay(task, from: item.date)
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date header
            Text(dateFormatter.string(from: item.date).uppercased())
                .font(.system(size: isSelected || isToday ? 20 : 16, weight: .bold))
                .foregroundColor(.black)
            
            // Show tasks list only when:
            // 1. This tile is selected, OR
            // 2. It's today's tile AND no other date is selected
            if isSelected || (isToday && Calendar.current.isDateInToday(selectedDate)) {
                // Task input
                HStack {
                    TextField("Add task", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            submitTask()
                        }
                    
                    Button(action: submitTask) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                
                // Tasks list with swipe actions
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(item.tasks.enumerated()), id: \.offset) { index, task in
                        VStack(spacing: 0) {
                            HStack(spacing: 8) {
                                Text("-")
                                    .foregroundColor(.black)
                                    .frame(width: 10, alignment: .leading)
                                
                                Text(task.trimmingCharacters(in: CharacterSet(charactersIn: "- ")))
                                    .foregroundColor(.black)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            
                            if index < item.tasks.count - 1 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 1)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .contentShape(Rectangle())
                        .background(Color.white.opacity(0.001))
                        .gesture(DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width < -threshold {
                                    withAnimation {
                                        handleDelete(task)
                                    }
                                } else if value.translation.width > threshold {
                                    withAnimation {
                                        handleMoveToNextDay(task)
                                    }
                                }
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    handleDelete(task)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                withAnimation {
                                    handleMoveToNextDay(task)
                                }
                            } label: {
                                Label("Tomorrow", systemImage: "arrow.right.circle")
                            }
                            .tint(.blue)
                        }
                    }
                }
            } else {
                // Show task count when collapsed
                Text("\(item.tasks.count) tasks")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(tileBackgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // Add a helper function to handle task submission
    private func submitTask() {
        guard !newTask.isEmpty else { return }
        
        // Keep keyboard focused
        let currentFocus = isTextFieldFocused
        
        // Add task
        onAddTask?()
        
        // Restore focus state
        DispatchQueue.main.async {
            isTextFieldFocused = currentFocus
        }
    }
}

struct DayTileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockDataService = PreviewContainer.dataService
        let previewItem = Item(date: Date(), tasks: [
            "First task",
            "Second task",
            "Third task with a longer description that might wrap"
        ])
        
        ScrollView {
            DayTileView(
                item: previewItem,
                isSelected: true,
                isToday: true,
                selectedDate: Date(),
                newTask: .constant(""),
                onAddTask: {},
                orderedWeekItems: [previewItem],
                dataService: mockDataService
            )
            .frame(maxWidth: .infinity)
            .padding()
        }
        .previewLayout(.sizeThatFits)
        .frame(height: 400)
        .background(Color.gray.opacity(0.1))
    }
} 