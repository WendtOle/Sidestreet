//
//  SessionActivityExtensionAttributes.swift
//  WalkTracker
//
//  Created by Ole on 17.10.26.
//
import ActivityKit
import Foundation

nonisolated struct SessionActivityExtensionAttributes: ActivityAttributes {
    nonisolated public struct ContentState: Codable, Hashable {
        var distanceMeter: Double
        var isTrackingQuestActive: Bool
        var isTrackingSoundRunning: Bool
    }

    var name: String
    var createdAt: Date
}
