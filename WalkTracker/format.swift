//
//  format.swift
//  WalkTracker
//
//  Created by Ole on 04.10.26.
//

import Foundation
func formatDuration(_ seconds: Double) -> String {
    let totalSeconds = Int(seconds)

    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    if hours > 0 {
        return String(format: "%02d:%02d", hours, minutes)
    } else {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
