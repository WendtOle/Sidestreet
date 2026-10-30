import SwiftUI

struct LocationEnabledAlert: View {
    let showAlert: Bool
    let isRecording: Bool
    @State var isAlertPresent: Bool = false
    
    var body: some View {
        
        if showAlert {
            Button {
                isAlertPresent = true
            } label: {
                Text("Location services is off").font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.right")
            }.buttonStyle(.glass)
                .alert("Turn on Location Services for your iPhone", isPresented: $isAlertPresent) {
                    Button("OK", role: .cancel) { }
                } message: {
                    let customMessage = isRecording
                    ? "You can save your current recording now, or turn on Location Services to continue recording.\n\n"
                    : ""
                    
                    Text("""
        Location Services must be turned on to record your walk.
        
        \(customMessage)To turn on Location Services:
        1. Open the Settings app
        2. Tap Privacy & Security
        3. Tap Location Services
        4. Turn on Location Services
        """)
                }
        }
    }
}
