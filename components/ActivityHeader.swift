//
//  ActivityHeader.swift
//  WalkTracker
//
//  Created by Ole on 18.10.26.
//

import SwiftUI


struct ActivityHeader: View {
    let appName: String
    let color: Color

    var body: some View {
        HStack {
            HStack(spacing: 7) {
                AppIcon()

                Text(appName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)
        }
    }
}
