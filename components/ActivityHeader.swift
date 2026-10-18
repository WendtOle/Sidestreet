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
                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 24, height: 24)
                    .background(
                        color,
                        in: RoundedRectangle(cornerRadius: 7)
                    )

                Text(appName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)
        }
    }
}
