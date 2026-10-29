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
    
    var frameSize: CGFloat {
        switch self {
        case .small:
            return 24
        case .large:
            return 32
        }
    }
}

struct AppIcon: View {
    let size: AppIconSize
    
    init(size: AppIconSize = .small) {
        self.size = size
    }
    
    var body: some View {
        Image("AppLogo")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size.frameSize, height: size.frameSize)
            .foregroundStyle(Color("AccentColor"))
    }
}
