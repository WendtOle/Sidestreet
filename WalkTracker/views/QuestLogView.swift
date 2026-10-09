//
//  QuestLogView.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI


struct QuestLogView: View {
    let quests: [Quest]
    let onSelect: (Quest) -> Void
    let onDelete: (Quest) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List{
                ForEach(quests) {quest in
                    Button {
                        onSelect(quest)
                        dismiss()
                    } label: {
                      QuestInformation(quest: quest)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            onDelete(quest)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }.navigationTitle("Questlog")
        }
    }
}

