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
            Image(systemName: quest.type.symbol)
            VStack(alignment: .leading) {
                Text(quest.type.name)
                    .font(.headline)
                Text(quest.createdAt, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .leading) {
                if quest.questReached {
                    Text("Done")
                        .font(.headline)
                }
            }
        }
    }
}
