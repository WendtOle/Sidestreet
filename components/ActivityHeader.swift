import SwiftUI


struct ActivityHeader: View {
    let appName: String

    var body: some View {
        HStack {
            HStack(spacing: 7) {
                AppIcon()

                Text(appName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)
        }
    }
}
