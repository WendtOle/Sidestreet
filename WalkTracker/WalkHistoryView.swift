//
//  WalkHistoryView.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI


struct WalkHistoryView: View {
    let walks: [Walk]
    let onSelect: (Walk) -> Void
    let onDelete: (Walk) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List{
                ForEach(walks) {walk in
                    Button {
                        onSelect(walk)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: walk.quest != nil ? (walk.questReached ? "flag.filled" : "point.bottomleft.forward.to.point.topright.scurvepath") : "figure.walk")
                                .font(.headline)
                            
                            VStack(alignment: .leading) {
                                Text(walk.createdAt, style: .date)
                                    .font(.headline)
                                Text(walk.createdAt, style: .time)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack {
                                Text("\(walk.totalDistance / 1000, specifier: "%.2f") km")
                                    .font(.headline)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            onDelete(walk)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }.navigationTitle("Historie")
        }
    }
}

