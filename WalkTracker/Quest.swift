//
//  Quest.swift
//  WalkTracker
//
//  Created by Ole on 04.10.26.
//

import CoreLocation
import SwiftData

enum QuestType: String, Codable, CaseIterable {
    case navigateClose
    case navigate
    case track
    case orbit
    case collect
    
    var name: String {
        switch self {
        case .navigateClose:
            return "Mini Quest"
        case .navigate:
            return "Navigation Quest"
        case .collect:
            return "Collection Quest"
        case .orbit:
            return "Circle Quest"
        case .track:
            return "Tracking Quest"
        }
    }
    
    var symbol: String {
        switch self {
        case .navigateClose:
            return "flag.pattern.checkered"
        case .navigate:
            return "flag.pattern.checkered.2.crossed"
        case .collect:
            return "point.bottomleft.forward.to.point.topright.scurvepath"
        case .orbit:
            return "circle"
        case .track:
            return "magnifyingglass"
        }
    }
    
    var distance: (min: Double, max: Double) {
        switch self {
        case .navigate, .collect, .orbit:
            return (300,1200)
        case .track, .navigateClose:
            return (100,600)
        }
    }
}

@Model
final class Quest {
    var id: UUID
    var createdAt: Date
    
    var target: GeoPoint
    var radius: Double = 30.0
    var questReached: Bool = false
    var type: QuestType
    var walk: Walk?
    var pinnedLocation: GeoPoint?
    
    init(referencePoint: CLLocation, questType: QuestType) {
        id = UUID()
        createdAt = Date()
        type = questType

        let distance = Double.random(in: questType.distance.min...questType.distance.max)
        target = getQuestTarget(startingPoint: referencePoint, distance: distance)
    }
}

func getQuestTarget (startingPoint: CLLocation, distance: Double) -> GeoPoint {
    let bearing = Double.random(in: 0..<360)
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
