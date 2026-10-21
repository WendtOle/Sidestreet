import SwiftUI

struct QuestTypeExplanation: View {
    let type: QuestType
    @State var isPresent: Bool = false
    
    var body: some View {
        Button {
            isPresent = true
        } label: {
            Image(systemName: "info.circle")
                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .adaptiveSheet(isPresent: $isPresent, title: type.longName)  {
            VStack(alignment: .leading, spacing: 12) {
                Text(type.helpDescription)
                    .font(.callout)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                Image(type.helpImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                
            }
        }
    }
}
