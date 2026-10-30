import SwiftUI

struct ApplicationAuthorizedAlert: View {
    let showAlert: Bool
    @State var isAlertPresent: Bool = false
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        
        if showAlert {
            Button {
                isAlertPresent = true
            } label: {
                Text("Location access is not granted")
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glass)
            .alert("Allow Location Access", isPresented: $isAlertPresent) {
                Button("Open Settings") {
                    guard let url = URL(
                        string: UIApplication.openSettingsURLString
                    ) else { return }

                    openURL(url)
                }

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("""
                Sidestreet needs location access to record your walk.

                Open Settings, tap Location, and select While Using the App. Enable Precise Location for accurate recording.
                """)
            }
        }
    }
}
