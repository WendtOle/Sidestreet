import SwiftUI


struct WalkHistoryView: View {
    @State var isPresent = false
    let walks: [Walk]
    let onSelect: (Walk) -> Void
    let onDelete: (Walk) -> Void
    @State private var recentExpanded = true
    @State private var olderExpanded = false
    
    private enum Group {
            case recent, older
    }

    private var groupedWalks: [Group: [Walk]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var groups: [Group: [Walk]] = [:]

        for walk in walks.sorted(by: { $0.createdAt > $1.createdAt }) {
            let day = calendar.startOfDay(for: walk.createdAt)
            let daysAgo = calendar.dateComponents(
                [.day],
                from: day,
                to: today
            ).day ?? 0

            let group: Group

            switch daysAgo {
            case 0...6:
                group = .recent
            case 7...:
                group = .older
            default:
                continue // Ignore future dates.
            }

            groups[group, default: []].append(walk)
        }

        return groups
    }
    
    var body: some View {
        let groups = groupedWalks
        
        Button {
            isPresent = true
        } label: {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 20))
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .adaptiveSheet(isPresent: $isPresent, title: "Past walks") {
            VStack(spacing: 16) {
                if let recent = groups[.recent] {
                    let distanceMeter = recent.reduce(0) { acc, walk in
                        return acc + walk.totalDistance
                    }
                    let distanceKm = distanceMeter / 1_000
                    let distanceText = distanceKm.formatted(
                        .number.precision(.fractionLength(1))
                    )
                    let duration = recent.reduce(0) { acc, walk in
                        return acc + walk.duration
                    }
                    let durationBy100 = duration / 3_600
                    let speed = distanceKm / durationBy100
                    let speedText = speed.formatted(
                        .number.precision(.fractionLength(1))
                    )
                    let averageDuration = duration / Double(7)
                    let averageDistanceKm = distanceKm / Double(7)
                    let averageDistanceText = averageDistanceKm.formatted(
                        .number.precision(.fractionLength(1))
                    )
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last week")
                        HStack {
                            Spacer()
                            SmallMetric(title: "Total distance") {
                                
                                Text("\(distanceText) km")
                            }
                            Spacer()
                            SmallMetric(title: "Average distance per day") {
                                Text("\(averageDistanceText) km")
                            }
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            SmallMetric(title: "Total duration") {
                                Text(formatDuration(duration))
                            }
                            Spacer()
                            SmallMetric(title: "Average duration per day") {
                                Text(formatDuration(averageDuration))
                            }
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            SmallMetric(title: "Average speed") {
                                Text("\(speedText) km/h" )
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(
                        Color.primary.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 24)
                    )
                }
                List{
                    if let recent = groups[.recent] {
                        DisclosureGroup(
                            "Last week (\(recent.count))",
                            isExpanded: $recentExpanded
                        ) {
                            ForEach(recent) { walk in
                                walkRow(walk)
                                .listRowInsets(
                                    EdgeInsets(
                                        top: 16,
                                        leading: 4,
                                        bottom: 16,
                                        trailing: 16
                                    )
                                )
                            }
                        }
                    }
                    
                    if let older = groups[.older] {
                        DisclosureGroup(
                            "Older (\(older.count))",
                            isExpanded: $olderExpanded
                        ) {
                            ForEach(older) { walk in
                                walkRow(walk)
                                .listRowInsets(
                                    EdgeInsets(
                                        top: 16,
                                        leading: 4,
                                        bottom: 16,
                                        trailing: 16
                                    )
                                )
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 250)
            }
        }
    }
    
    private func walkRow(_ walk: Walk) -> some View {
        WalkInformation(walk: walk)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete(walk)
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}

struct SmallMetric<Value: View>: View {
    let title: String
    @ViewBuilder var value: () -> Value

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            value()
                .font(.system(size: 22))
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
