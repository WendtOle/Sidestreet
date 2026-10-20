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
        .sheet(isPresented: $isPresent) {
            VStack(alignment: .leading, spacing: 12) {
                HStack{
                    Spacer()
                    Button("Done") {
                        isPresent = false
                    }
                }
                Spacer()
                Label(
                    type.name,
                    systemImage: type.symbol
                )
                .font(.body.bold())
                
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
                
                Spacer()
            }
            .padding(24)
            .presentationDetents([.medium])
        }
    }
}
