import SwiftUI
import CoreLocation
import MapKit

struct MapStyleSelector: View {
    let mapCameraPosition: MapCameraPosition
    @State var isPresent: Bool = false
    @Binding var style: Style
    @Binding var showsHeatMap: Bool
    
    var body: some View {
        Button {
            isPresent = true
        } label: {
            Image(systemName: "square.3.layers.3d")
                .font(.system(size: 20))
                .tint(.primary)
        }
        .adaptiveSheet(isPresent: $isPresent, title: "Map Modes") {
            VStack {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Style.allCases) { option in
                        styleCard(option)
                    }
                }
                Toggle(isOn: $showsHeatMap) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Visit history")

                        Text("Recently visited areas appear more prominent.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .toggleStyle(.switch)
                .tint(.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Color.primary.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 24)
                )
            }
        }
    }
    
    private func styleCard(_ option: Style) -> some View {
        let isSelected = style == option
        let shape = RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        )
        let initialPosition: MapCameraPosition = .camera(
            MapCamera(
                centerCoordinate: CLLocationCoordinate2D(
                    latitude: 52.517104571752455, longitude: 13.461119891466105
                ),
                distance: 1_000,
                heading: 0,
                pitch: 0
            )
        )

        return Button {
            style = option
        } label: {
            VStack(spacing: 0) {
                Map(
                    initialPosition: initialPosition,
                    interactionModes: []
                )
                .mapStyle(option.mapStyle)
                .mapControls { }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(6)
                .overlay {
                    if isSelected {
                        shape.strokeBorder(Color.accentColor, lineWidth: 2)
                    }
                }
                .contentShape(shape)

                Text(option.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    .padding(.bottom, 14)
            }
            
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}



enum Style: String, CaseIterable, Identifiable {
        case standard = "Standard"
        case satellite = "Satellite"

        var id: Self { self }

    var mapStyle: MapStyle {
        switch self {
        case .standard:
            return .standard(
                pointsOfInterest: .excludingAll,
                showsTraffic: false
            )

        case .satellite:
            return .hybrid(
                pointsOfInterest: .excludingAll,
                showsTraffic: false
            )
        }
    }
    }
