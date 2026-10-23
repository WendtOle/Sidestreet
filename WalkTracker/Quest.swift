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
    case collect
    
    var name: String {
        switch self {
        case .navigate:
            return "Navigate"
        case .collect:
            return "Collect"
        case .track:
            return "Track"
        }
    }
    
    var longName: String {
        switch self {
        case .navigate:
            return "Navigation challenge"
        case .collect:
            return "Collecting challenge"
        case .track:
            return "Tracking challenge"
        }
    }
    
    var symbol: String {
        switch self {
        case .navigate:
            return "flag.pattern.checkered"
        case .collect:
            return "point.bottomleft.forward.to.point.topright.scurvepath"
        case .track:
            return "magnifyingglass"
        }
    }
    
    var helpDescription: String {
        switch self {
        case .navigate:
            return """
            Find your way to a randomly chosen destination.
            """

        case .track:
            return """
            Find a randomly chosen destination using only sound.

            Turn on sound and follow the beeps. They get faster \
            as you move closer and slower as you move farther away.
            """

        case .collect:
            return """
            Explore your neighbourhood and collect coins to \
            reach the target score.

            Coins in places you haven’t visited recently \
            are worth more points.
            """
        }
    }

    var helpImageName: String {
        switch self {
        case .navigate: return "challenge-help-navigate"
        case .track:    return "challenge-help-track"
        case .collect:  return "challenge-help-collect"
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
