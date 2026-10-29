import AppIntents
import WidgetKit
import SwiftUI

struct SessionActivityExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityExtensionAttributes.self) { context in
            VStack(spacing: 0) {
                VStack(spacing: 18) {
                    ActivityHeader(appName: "Sidestreet")

                    WalkProgress(
                        createdAt: context.attributes.createdAt,
                        distanceKm: context.state.distanceMeter / 1_000) {
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
                                    .foregroundStyle(Color("AccentColor"))
                                    .frame(width: 58, height: 58)
                                    .background(
                                        Color("AccentColor").opacity(0.15),
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
                    .foregroundStyle(Color("AccentColor"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color("AccentColor").opacity(0.15))
                }
            }
            .activityBackgroundTint(.clear)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    AppIcon(size: .large)
                        .accessibilityLabel("Sidestreet")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    islandDistance(context.state.distanceMeter)
                        .font(.title2.weight(.semibold))
                }
            } compactLeading: {
                AppIcon()
                    .accessibilityLabel("Sidestreet")
            } compactTrailing: {
                islandDistance(context.state.distanceMeter)
                    .font(.caption.weight(.semibold))
            } minimal: {
                AppIcon()
                    .accessibilityLabel("Sidestreet walk in progress")
            }
            .keylineTint(Color("AccentColor"))
        }
    }

    private func islandDistance(_ meters: Double) -> some View {
        let distance = meters.isFinite ? max(0, meters) : 0
        // Switch at the rounded metre boundary to avoid showing "1,000 m".
        let usesKilometers = distance.rounded() >= 1_000
        let value = usesKilometers ? distance / 1_000 : distance
        let number = value.formatted(
            .number.precision(.fractionLength(usesKilometers ? 1 : 0))
        )
        let unit = usesKilometers ? "km" : "m"

        return Text("\(number) \(unit)")
            .monospacedDigit()
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .accessibilityLabel("Distance walked")
            .accessibilityValue(Text("\(number) \(usesKilometers ? "kilometers" : "meters")"))
    }
}
