import SwiftUI

struct LocationUpdatePendingAlert: View {
    let isLocationUpdatePending: Bool
    @State var isAlertPresent: Bool = false
    
    var body: some View {
        HStack {
            if isLocationUpdatePending {
                Button{
                    isAlertPresent = true
                } label: {
                    ProgressView()
                        .controlSize(.small)
                    
                    Text("Finding your location…").font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.glass)
            }
        }
        .alert("Waiting for location update", isPresented: $isAlertPresent) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Sidestreet needs your current location before you can create a challenge. This may take a moment. For better reception, try moving to an open area.")
        }
    }
}
