import SwiftUI
import SwiftData

struct AppMenu: View {
    @State var isAboutPresent: Bool = false
    @State var isSettingsPresent: Bool = false
    
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<SettingsData> { $0.key == "app" })
    private var settingsRecords: [SettingsData]
    
    var body: some View {
        if let settings = settingsRecords.first {
            @Bindable var settings = settings
            Menu {
                Button("Settings") {
                    isSettingsPresent = true
                }
                
                Button("About") {
                    isAboutPresent = true
                }
            } label: {
                AppIcon(size: .large)
                    .padding(8)
                    .glassEffect(
                            .regular,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                    .padding(.horizontal, 18)
            }
            .alert("Sidestreet", isPresented: $isAboutPresent) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("""
            Sidestreet was created by Ole Wendt.
            
            Visit ole-wendt.de for more projects.
            """)
            }
            .adaptiveSheet(isPresent: $isSettingsPresent, title: "Settings") {
                VStack (spacing: 24) {
                    Toggle("Enable discarding walks", isOn: $settings.enableDiscardingWalks)
                        .toggleStyle(.switch)
                        .tint(.blue)
                    Toggle("Intro dismissed", isOn: $settings.introDismissed)
                        .toggleStyle(.switch)
                        .tint(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Color.primary.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 24)
                )
            }
        }
    }
}
