//
//  AppIcon.swift
//  WalkTracker
//
//  Created by Ole on 21.10.26.
//

import SwiftUI

enum AppIconSize {
    case small
    case large
    
    var fontSize: CGFloat {
        switch self {
        case .small:
            return 13
        case .large:
            return 20
        }
    }
    
    var frameSize: CGFloat {
        switch self {
        case .small:
            return 24
        case .large:
            return 36
        }
    }
}

struct AppIcon: View {
    let size: AppIconSize
    
    init(size: AppIconSize = .small) {
        self.size = size
    }
    
    var body: some View {
        Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
            .font(.system(size: size.fontSize, weight: .medium))
            .foregroundStyle(.black)
            .frame(width: size.frameSize, height: size.frameSize)
            .background(
                .green,
                in: RoundedRectangle(cornerRadius: 7)
            )
    }
}
