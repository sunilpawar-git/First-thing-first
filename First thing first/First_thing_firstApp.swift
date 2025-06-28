//
//  First_thing_firstApp.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftUI
import SwiftData

@main
struct First_thing_firstApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}