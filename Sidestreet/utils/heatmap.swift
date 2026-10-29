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
    let maxValue = 21
    let daysOld = max(0, maxValue - days)
    let output = Double(daysOld) / Double(maxValue)
    return pow(output,4)
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
    return countedPoints
}
