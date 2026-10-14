//
//  RecordingButton.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//

import SwiftUI
import Combine

struct RecordingButton: View {
    let activeWalk: Walk?
    let startRecording: () -> Void
    let stopRecording: () -> Void
     
    var body: some View {
        HStack(spacing: 12) {
            Button {
                if activeWalk != nil {
                    stopRecording()
                } else {
                    startRecording()
                }
            } label: {
                if let walk = activeWalk {
                    HStack(spacing: 20) {
                        let formattedDistance = walk.totalDistance < 1_000 ? "\(Int(walk.totalDistance)) m" : String(format: "%.2f km", walk.totalDistance / 1_000)
                        Text(formattedDistance)
                        Text(formatDuration(walk.duration))
                        Image(systemName: "stop.fill")
                            .font(.system(size: 28, weight: .bold))
                            .frame(width: 72, height: 50)
                    }
                    .padding(.leading, 12)
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .frame(width: 72, height: 50)
                }
            }
            .buttonStyle(.glassProminent)
        }
    }
}
