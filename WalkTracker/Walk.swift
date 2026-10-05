//
//  Walk.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI
import CoreLocation
import SwiftData

@Model
final class Walk {
    var id: UUID
    var createdAt: Date
    var routeCoordinates: [RoutePoint] = []
    var totalDistance: CLLocationDistance = 0
    var duration: Double = 0
    
    var quest: Quest?
    var questReached: Bool = false

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

struct WalkInformation: View {
    let walk: Walk
    
    var body: some View {
        HStack {
            WalkImage(hasQuest: walk.quest != nil, reachedQuest: walk.questReached)
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text(walk.createdAt, style: .date)
                    .font(.headline)
                Text(walk.createdAt, style: .time)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text("\(walk.totalDistance / 1000, specifier: "%.2f") km")
                    .font(.headline)
                Text(formatDuration(walk.duration))
                    .font(.subheadline)
            }
        }
    }
}

struct WalkImage: View {
    let hasQuest: Bool
    let reachedQuest: Bool
    
    var body: some View {
        Image(systemName: hasQuest ? (reachedQuest ? "flag.fill" : "point.bottomleft.forward.to.point.topright.scurvepath") : "figure.walk")
    }
}
