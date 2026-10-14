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
            VStack(alignment: .leading) {
                HStack {
                    Text(
                        walk.createdAt,
                        format: .dateTime.day().month(.twoDigits).year()
                    )
                        .font(.headline)
                    Text("-")
                    Text(walk.createdAt, style: .time)
                        .font(.headline)
                }
                if walk.quests.count > 0 {
                    Text("\(walk.quests.count) Quest\(walk.quests.count > 1 ? "s" : "") completed")
                        .font(.subheadline)
                } else {
                    Text("")
                }
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
    let quest: Quest?
    
    var body: some View {
        Image(systemName: quest?.data.type.symbol ?? "figure.walk")
    }
}
