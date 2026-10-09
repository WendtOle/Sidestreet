//
//  WalkInformation.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//

import SwiftUI

struct WalkInformation: View {
    let walk: Walk
    
    var body: some View {
        HStack {
            WalkImage(hasQuest: walk.quest != nil, reachedQuest: walk.quest?.questReached == true)
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
