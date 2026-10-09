//
//  QuestInformation.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//

import SwiftUI

struct QuestInformation: View {
    let quest: Quest
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Daily Quest")
                    .font(.headline)
                Text(quest.createdAt, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .leading) {
                Text(quest.questReached ? "completed" : "not completed")
                    .font(.headline)
            }
        }
    }
}
