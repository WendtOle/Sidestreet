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
    let onCreate: (QuestType) async -> Void
    @State var isLoading: Bool = false
    @State var showQuestTypeDialog: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List{
                ForEach(quests) {quest in
                    Button {
                        onSelect(quest)
                        dismiss()
                    } label: {
                        HStack {
                            QuestInformation(quest: quest)
                            Spacer()
                            if quest.questReached {
                                Text("Done")
                                    .font(.headline)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            onDelete(quest)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Questlog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                    .labelStyle(.iconOnly)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(QuestType.navigate.name, systemImage: QuestType.navigate.symbol) {
                            Task {
                                defer {isLoading = true}
                                await onCreate(.navigate)
                            }
                        }

                        Button(QuestType.track.name, systemImage: QuestType.track.symbol) {
                            Task {
                                defer {isLoading = true}
                                await onCreate(.track)
                            }
                        }

                        Button(QuestType.collect.name, systemImage: QuestType.collect.symbol) {
                            Task {
                                defer {isLoading = true}
                                await onCreate(.collect)
                            }
                        }.disabled(true)

                        Button(QuestType.orbit.name, systemImage: QuestType.orbit.symbol) {
                            Task {
                                defer {isLoading = true}
                                await onCreate(.orbit)
                            }
                        }.disabled(true)
                    } label: {
                        ZStack {
                            Label("Create Quest", systemImage: "plus")
                                .labelStyle(.iconOnly)
                                .opacity(isLoading ? 0 : 1)

                            if isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                        .frame(width: 24, height: 24)
                    }
                    .disabled(isLoading)
                    .accessibilityLabel(
                        isLoading ? "Creating Quest" : "Create Quest"
                    )
                }
            }
        }
    }
}

