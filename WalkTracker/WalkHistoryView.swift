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
                                Text(walk.questReached ? "Done" : "Failed")
                                    .font(.headline)
                            }
                        }
                    }
                }
            }.navigationTitle("Historie")
        }
    }
}

