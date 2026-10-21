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
        List{
            ForEach(walks) {walk in
                Button {
                    onSelect(walk)
                    dismiss()
                } label: {
                    WalkInformation(walk: walk)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        onDelete(walk)
                    } label: {
                        Label("Löschen", systemImage: "trash")
                    }
                }
            }
        }
    }
}

