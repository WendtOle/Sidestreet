//
//  QuestData.swift
//  WalkTracker
//
//  Created by Ole on 13.10.26.
//

import CoreLocation
import SwiftData

struct Target: Codable {
    var point: GeoPoint
    var value: Double
}

@Model
class QuestData {
    var id: UUID
    var createdAt: Date
    
    var targets: [Target]
    var questReached: Bool = false
    var type: QuestType
    var walk: Walk?
    
    init(targets: [Target], type: QuestType) {
        self.id = UUID()
        self.createdAt = Date()
        self.targets = targets
        self.type = type
    }
}

