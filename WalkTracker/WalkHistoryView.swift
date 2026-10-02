//
//  WalkHistoryView.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI


struct WalkHistoryView: View {
    let walks: [Walk]
    @Binding var selectedWalk: Walk?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack{
            ForEach(walks) {walk in
                Text("\(walk.createdAt)")
                Text("\(walk.totalDistance / 1000) km")
                Button("open") {
                    selectedWalk = walk
                    dismiss()
                }
            }
        }
    }
}

