//
//  SessionActivityExtensionLiveActivity.swift
//  SessionActivityExtension
//
//  Created by Ole on 17.10.26.
//

import AppIntents
import WidgetKit
import SwiftUI

private enum ActivityStyle {
    static let accent = Color.green
    static let softAccent = Color.green.opacity(0.15)
}

struct SessionActivityExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityExtensionAttributes.self) { context in
            VStack(spacing: 0) {
                VStack(spacing: 18) {
                    ActivityHeader(appName: "WalkTracker", color: ActivityStyle.accent)

                    WalkProgress(
                        createdAt: context.attributes.createdAt,
                        distanceKm: context.state.distanceMeter / 1_000,
                        accent: ActivityStyle.accent,
                        softAccent: ActivityStyle.softAccent) {
                            if context.state.isTrackingQuestActive {
                                Button(intent: ToggleTrackingSoundIntent()) {
                                    VStack(spacing: 5) {
                                        Image(
                                            systemName: context.state.isTrackingSoundRunning
                                            ? "speaker.wave.3"
                                            : "speaker.slash"
                                        )
                                        .font(.system(size: 17, weight: .medium))
                                    }
                                    .foregroundStyle(ActivityStyle.accent)
                                    .frame(width: 58, height: 58)
                                    .background(
                                        ActivityStyle.softAccent,
                                        in: RoundedRectangle(cornerRadius: 18)
                                    )
                                }
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
                
                if false {
                    HStack(spacing: 7) {
                        Image(systemName: "checkmark.circle.fill")

                        Text("Challenge complete")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundStyle(ActivityStyle.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(ActivityStyle.softAccent)
                }
            }
            .activityBackgroundTint(.clear)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("B")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
