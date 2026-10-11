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
    let output = Double(4) / (Double(days + 1))
    return output
}

func calculateHeatmap (walks: [Walk]) -> [(point: GeoPoint, count: Double)] {
    let heatmapStarted = Date()
    let walkPoints: [(points:[GeoPoint],modifier: Double)] = walks.map { walk in
        var seen = Set<[Double]>()

        return (points: walk.routeCoordinates.filter { point in
            seen.insert(getBinnedCoordinates(point)).inserted
        }
                , modifier: getDayModifier(walk.createdAt))
    }
    let counts = walkPoints.reduce(into: [[Double]: Double]()) { result, tuple in
        for point in tuple.points {
            result[getBinnedCoordinates(point), default: 0] += tuple.modifier
        }
    }
    let countedPoints = counts.map { entry in
        (
            point: GeoPoint(
                latitude: entry.key[0],
                longitude: entry.key[1]
            ),
            count: entry.value
        )
    }
    let _ = print(
        "Heatmap: \(countedPoints.count) circles, " +
        "\(Date().timeIntervalSince(heatmapStarted) * 1_000) ms"
    )
    return countedPoints
}
