//
//  SettingsData.swift
//  WalkTracker
//
//  Created by Ole on 21.10.26.
//

import SwiftData
import Foundation

@Model
final class SettingsData {
    @Attribute(.unique)
    private(set) var key: String = "app"
    
    var introDismissed: Bool = false
    var enableDiscardingWalks: Bool = false
    
    private init() {}
    
    @MainActor
    static func createIfNeeded(in context: ModelContext) throws {
        var request = FetchDescriptor<SettingsData>(
            predicate: #Predicate { $0.key == "app" }
        )
        request.fetchLimit = 1

        if try context.fetch(request).isEmpty {
            context.insert(SettingsData())
            try context.save()
        }
    }
}

