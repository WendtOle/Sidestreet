//
//  Metric.swift
//  WalkTracker
//
//  Created by Ole on 18.10.26.
//

import SwiftUI

struct Metric<Value: View>: View {
    let title: String
    @ViewBuilder var value: () -> Value

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            value()
                .font(.system(size: 30, weight: .medium))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
