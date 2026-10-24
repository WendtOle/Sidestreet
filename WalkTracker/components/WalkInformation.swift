//
//  WalkInformation.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//

import SwiftUI
import MapKit

struct WalkInformation: View {
    @State var isPresent: Bool = false
    let walk: Walk
    
    var body: some View {
        Button {
            isPresent = true
        }
        label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(walk.createdAt.formatted())
                    }
                    if let quest = walk.quests.first {
                        Text(quest.questReached ? "Challenge completed" : "Challenge failed")
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(walk.totalDistance / 1000, specifier: "%.2f") km")
                    Text(formatDuration(walk.duration))
                }
            }
        }
        .adaptiveSheet(isPresent: $isPresent, title: "\(walk.createdAt.formatted())") {
            WalkSummary(walk: walk)
        }
    }
}

struct WalkImage: View {
    let quest: Quest?
    
    var body: some View {
        Image(systemName: quest?.data.type.symbol ?? "figure.walk")
    }
}

struct WalkSummary: View {
    let walk: Walk
    
    var body: some View {
        let distanceKm = walk.totalDistance / 1_000
        let distanceText = distanceKm.formatted(
            .number.precision(.fractionLength(1))
        )
        let durationBy100 = walk.duration / 3_600
        let speed = distanceKm / durationBy100
        let speedText = speed.formatted(
            .number.precision(.fractionLength(1))
        )
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                SmallMetric(title: "Distance") {
                    Text("\(distanceText) km")
                }
                Spacer()
                SmallMetric(title: "Duration") {
                    Text(formatDuration(walk.duration))
                }
                Spacer()
                SmallMetric(title: "Speed") {
                    Text("\(speedText) km/h" )
                }
                Spacer()
            }
            
            Map(interactionModes: []) {
                MapPolyline(coordinates: walk.coordinates).stroke(.orange, lineWidth: 5)
                ForEach(walk.quests, id: \.id) { quest in
                    QuestFactory.mapElements(questData: quest, walkFinished: true)
                }
            }
            .frame(minHeight: 300)
            if let quest = walk.quests.first {
                Text(quest.questReached ? "Challenge completed" : "Challenge failed").font(.body)
            }
        }
    }
}
