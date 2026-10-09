//
//  RecordingButton.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//

import SwiftUI
import Combine

struct RecordingButton: View {
    @Binding var locationManager: LocationManager
    @Binding var pendingWalk: Walk?
    @Binding var showSaveConfirmation: Bool
    @Binding var selectedWalk: Walk?
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                if locationManager.isRecording {
                    locationManager.stopRecording()
                    guard let walk = locationManager.currentWalk else {
                        return
                    }
                    pendingWalk = walk
                    showSaveConfirmation = true
                } else {
                    locationManager.startRecording()
                    selectedWalk = nil
                }
            } label: {
                if locationManager.isRecording {
                    HStack(spacing: 20) {
                        if let walk = locationManager.currentWalk {
                            let formattedDistance = walk.totalDistance < 1_000 ? "\(Int(walk.totalDistance)) m" : String(format: "%.2f km", walk.totalDistance / 1_000)
                            Text(formattedDistance)
                            Text(formatDuration(walk.duration))
                        }
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
