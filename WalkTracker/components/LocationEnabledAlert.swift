//
//  LocationEnabledAlert.swift
//  WalkTracker
//
//  Created by Ole on 19.10.26.
//

import SwiftUI

struct LocationEnabledAlert: View {
    let isLocationServiceEnabled: Bool
    let isRecording: Bool
    @State var isAlertPresent: Bool = false
    
    var body: some View {
        
        if !isLocationServiceEnabled {
            Button {
                isAlertPresent = true
            } label: {
                Text("Location Services is Off").font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.right")
            }.buttonStyle(.glass)
                .alert("Turn on Location Services for your iPhone", isPresented: $isAlertPresent) {
                    Button("OK", role: .cancel) { }
                } message: {
                    let customMessage = isRecording
                    ? "You can save your current recording now, or turn on Location Services to continue recording.\n\n"
                    : ""
                    
                    Text("""
        Location Services must be turned on to record your walk.
        
        \(customMessage)To turn on Location Services:
        1. Open the Settings app
        2. Tap Privacy & Security
        3. Tap Location Services
        4. Turn on Location Services
        """)
                }
        }
    }
}
