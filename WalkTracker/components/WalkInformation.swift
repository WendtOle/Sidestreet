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
        .adaptiveSheet(isPresent: $isPresent) {
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
        
        let shape = RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        )
        
        VStack(spacing: 12) {
            if let quest = walk.quests.first {
                HStack(spacing: 8) {
                    Image(systemName: quest.type.symbol)
                    Text("\(quest.type.longName) \(quest.questReached ? "completed" : "failed")").font(.headline.weight(.semibold))
                }
                HStack(spacing: 8) {
                    QuestFactory.progressIndicatorElement(questData: quest)
                }
            }
            Map(interactionModes: []) {
                MapPolyline(coordinates: walk.coordinates).stroke(.orange, lineWidth: 5)
                ForEach(walk.quests, id: \.id) { quest in
                    QuestFactory.mapElements(questData: quest, walkFinished: true)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(6)
            .overlay {
                if let quest = walk.quests.first {
                    shape.strokeBorder(quest.questReached ? .green : .red, lineWidth: 2)
                }
            }
            .contentShape(shape)
            .frame(minHeight: 350)
            .overlay(alignment: .bottomTrailing) {
                Group {
                    HStack(spacing:8) {
                        Text("\(distanceText) km").font(.callout)
                        Text(formatDuration(walk.duration)).font(.callout)
                        Text("\(speedText) km/h").font(.callout)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .glassEffect()
                }
                .padding(12)
            }
            .overlay(alignment: .topLeading) {
                TextBubble(text: "\(walk.createdAt.formatted())")
                    .padding(12)
            }
        }
    }
}

private struct TextBubble: View {
    let text: String
    
    var body: some View {
        Text(text).font(.callout)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .glassEffect()
    }
    
}
