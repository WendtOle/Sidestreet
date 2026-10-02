//
//  Walk.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import CoreLocation
import SwiftData

@Model
final class Walk {
    var id: UUID
    var createdAt: Date
    var routeCoordinates: [RoutePoint] = []
    var totalDistance: CLLocationDistance = 0

    init() {
        id = UUID()
        createdAt = Date()
    }
        
    var coordinates: [CLLocationCoordinate2D] {
        routeCoordinates.map {
            CLLocationCoordinate2D(
                latitude: $0.latitude,
                longitude: $0.longitude
            )
        }
    }
}
