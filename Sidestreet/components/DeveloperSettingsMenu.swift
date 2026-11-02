import SwiftUI
import SwiftData

struct DeveloperSettingsMenu: View {
    let fullfillChallenge: () -> Void
    let createTutorialChallenge: () -> Void
    @State var showDevMenu: Bool = true
    
    var body: some View {
        if showDevMenu {
            Menu {
                Button("Fullfill challenge") {
                    fullfillChallenge()
                }
                Button("Create tutorial challenge") {
                    createTutorialChallenge()
                }
                Button("Hide dev menu for 3s") {
                    showDevMenu = false
                    
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(3))
                        showDevMenu = true
                    }
                }
            } label: {
                Image(systemName: "apple.terminal")
                    .font(.system(size: 20))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
    }
}
