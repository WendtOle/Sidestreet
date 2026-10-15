//
//  Quest.swift
//  WalkTracker
//
//  Created by Ole on 04.10.26.
//

import CoreLocation
import SwiftData
import MapKit
import SwiftUI

enum QuestType: String, Codable, CaseIterable {
    case navigate
    case track
    case orbit
    case collect
    
    var name: String {
        switch self {
        case .navigate:
            return "Navigate"
        case .collect:
            return "Collect"
        case .orbit:
            return "Circle"
        case .track:
            return "Track"
        }
    }
    
    var symbol: String {
        switch self {
        case .navigate:
            return "flag.pattern.checkered"
        case .collect:
            return "point.bottomleft.forward.to.point.topright.scurvepath"
        case .orbit:
            return "circle"
        case .track:
            return "magnifyingglass"
        }
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
