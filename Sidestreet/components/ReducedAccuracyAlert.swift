import SwiftUI

struct ReducedAccuracyAlert: View {
    let showAlert: Bool
    @State var isAlertPresent: Bool = false
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        
        if showAlert {
            Button {
                isAlertPresent = true
            } label: {
                Text("Precise location is off")
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glass)
            .alert("Enable Precise Location", isPresented: $isAlertPresent) {
                Button("Open Settings") {
                    guard let url = URL(
                        string: UIApplication.openSettingsURLString
                    ) else { return }

                    openURL(url)
                }

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("""
                Sidestreet can only access your approximate location. Enable Precise Location to record your route and find nearby challenge targets.

                Open Settings, tap Location, and turn on Precise Location.
                """)
            }
        }
    }
}
