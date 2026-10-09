//
//  InformationContainer.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//

import SwiftUI

enum InformationEntity {
    case quest(Quest)
    case walk(Walk)
}

struct InformationContainer: View {
    let entity: InformationEntity
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            switch entity {
            case .walk(let walk):
                WalkInformation(walk: walk)

            case .quest(let quest):
                QuestInformation(quest: quest)
            }

            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .padding(.horizontal)
    }
}
