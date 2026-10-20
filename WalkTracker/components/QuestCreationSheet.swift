import SwiftUI

enum ChallengeDuration: Hashable {
    case short
    case long
}

struct QuestCreationSheet: View {
    let createQuest: (QuestType, Bool) -> Void
    @State var choosenType: QuestType = QuestType.navigate
    @State var duration: ChallengeDuration = ChallengeDuration.long
    @Binding var isQuestCreationPresented: Bool

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button("Cancel") {
                    isQuestCreationPresented = false
                }
                Spacer()
            }
            
            Text("Find your challenge").font(.title)
            
            VStack(spacing: 8) {
                HStack {
                    Text("What kind?").font(.headline)
                    Spacer()
                }
                Picker("Challenge type", selection: $choosenType) {
                    ForEach(QuestType.allCases, id: \.self) { type in
                        Label(type.name, systemImage: type.symbol)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                VStack(alignment: .leading, spacing: 12) {
                    Image(choosenType.helpImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 130)
                        .frame(maxWidth: .infinity)
                    
                    
                    Label(
                        choosenType.name,
                        systemImage: choosenType.symbol
                    )
                    .font(.callout.bold())
                    
                    Text(choosenType.helpDescription)
                        .font(.subheadline)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
            }
            .padding()
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("How long?").font(.headline.bold())
                Text("Short challenges keep you close to your starting point. Long challenges take you farther away.").font(.subheadline)
                Picker("Duration", selection: $duration) {
                    Text("Short").tag(ChallengeDuration.short)
                    Text("Long").tag(ChallengeDuration.long)
                }
                .pickerStyle(.segmented)
            }
            .padding()
                        
            Button {
                createQuest(choosenType, duration == ChallengeDuration.short)
                isQuestCreationPresented = false
            } label: {
                Text("Start challenge")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.glassProminent)
        }
        
    }
}
