//
//  Content.swift
//  WalkTracker
//
//  Created by Ole on 18.10.26.
//

import SwiftUI

struct WalkProgress<Value: View>: View {
    let createdAt: Date
    let distanceKm: Double
    @ViewBuilder var value: () -> Value

    var distanceText: String {
        distanceKm.formatted(
            .number.precision(.fractionLength(2))
        )
    }

    var body: some View {
        
        HStack(spacing: 20) {
            Metric(title: "Distance") {
                HStack {
                    Text("\(distanceText)")
                    Text("km").font(.subheadline)
                }
            }
            
            Metric(title: "Duration") {
                Text(createdAt,style: .timer)
                    .monospacedDigit()
            }
            
            value()
        }
    }
}
