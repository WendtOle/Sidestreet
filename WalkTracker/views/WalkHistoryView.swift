//
//  WalkHistoryView.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI


struct WalkHistoryView: View {
    @State var isPresent = false
    let walks: [Walk]
    let onSelect: (Walk) -> Void
    let onDelete: (Walk) -> Void
    
    var body: some View {
        Button {
            isPresent = true
        } label: {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 20))
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .sheet(isPresented: $isPresent) {
            SheetWrapper(isPresented: $isPresent, title: "Historie") {
                List{
                    ForEach(walks) {walk in
                        Button {
                            onSelect(walk)
                            isPresent = false
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
            .presentationDetents([.large])
        }
    }
}

