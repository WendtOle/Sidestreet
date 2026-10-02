//
//  WalkTrackerApp.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI
import SwiftData

@main
struct WalkTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Walk.self)
    }
}
