import SwiftUI

struct InformationContainer<Content:View>: View {
    private let content: Content
    let onClose: () -> Void
    
    init(@ViewBuilder content: () -> Content, onClose: @escaping () -> Void) {
        self.content = content()
        self.onClose = onClose
    }

    var body: some View {
        HStack(spacing: 20) {
            content
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
        }
        .padding()
        .glassEffect(
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}
