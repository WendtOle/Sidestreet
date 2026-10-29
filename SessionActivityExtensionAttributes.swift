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
