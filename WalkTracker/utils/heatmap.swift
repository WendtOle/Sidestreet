//
//  heatmap.swift
//  WalkTracker
//
//  Created by Ole on 11.10.26.
//

import Foundation

func getBinnedCoordinates(_ point: GeoPoint) -> [Double] {
    // 40m x 40m
    return [rounded(point.latitude, step: 0.00035),
        rounded(point.longitude, step: 0.000559)
    ]
}

func getDayModifier(_ createdAt: Date) -> Double {
    let calendar = Calendar.current

    let days = calendar.dateComponents(
        [.day],
        from: calendar.startOfDay(for: createdAt),
        to: calendar.startOfDay(for: Date())
    ).day ?? 0
    let output = Double(2) / (Double(days + 1))
    return output
}
