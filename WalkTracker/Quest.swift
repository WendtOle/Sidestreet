//
//  Quest.swift
//  WalkTracker
//
//  Created by Ole on 04.10.26.
//

import CoreLocation
import SwiftData

@Model
final class Quest {
    var id: UUID
    var createdAt: Date
    
    var target: GeoPoint
    var radius: Double = 30.0
    var questReached: Bool = false
    
    init(referencePoint: CLLocation) {
        id = UUID()
        createdAt = Date()
        target = getQuestTarget(startingPoint: referencePoint)
    }
}

func getQuestTarget (startingPoint: CLLocation) -> GeoPoint {
    let bearing = Double.random(in: 0..<360)
    let distance = Double.random(in: 200...500)
    
    let target = destination(from: startingPoint.coordinate, distance: distance, bearing: bearing)
    return GeoPoint(latitude: target.latitude, longitude: target.longitude)
}

func destination(
    from coordinate: CLLocationCoordinate2D,
    distance: CLLocationDistance,
    bearing: CLLocationDirection
) -> CLLocationCoordinate2D {

    let earthRadius = 6_371_000.0

    let latitude1 = coordinate.latitude * .pi / 180
    let longitude1 = coordinate.longitude * .pi / 180
    let bearingRadians = bearing * .pi / 180

    let angularDistance = distance / earthRadius

    let latitude2 = asin(
        sin(latitude1) * cos(angularDistance)
        + cos(latitude1)
        * sin(angularDistance)
        * cos(bearingRadians)
    )

    let longitude2 = longitude1 + atan2(
        sin(bearingRadians) * sin(angularDistance) * cos(latitude1),
        cos(angularDistance) - sin(latitude1) * sin(latitude2)
    )

    return CLLocationCoordinate2D(
        latitude: latitude2 * 180 / .pi,
        longitude: longitude2 * 180 / .pi
    )
}


func isQuestReached(quest: Quest, location: CLLocation) -> Bool {
    let distance = location.distance(from: CLLocation(latitude: quest.target.latitude, longitude: quest.target.longitude))
    return distance <= quest.radius
}
