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
    var collected: Bool = false

    var collectionPoints: Int {
        // Values are normalized to 0...1; every collectible earns at least one point.
        max(1, Int((value * 100).rounded()))
    }
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

