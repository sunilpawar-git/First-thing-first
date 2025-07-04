//
//  ContentView.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
            
            WeeklyPlannerView()
                .tabItem {
                    Label("Week", systemImage: "calendar.day.timeline.left")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}