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
        VStack(alignment: .leading) {
            HStack {
                Button("Cancel") {
                    isQuestCreationPresented = false
                }
                Spacer()
            }
            .padding(.bottom, 8)
            
            Text("Find your challenge").font(.title)
            Text("Pick what you want to focus on.").font(.subheadline)
            
            Form {
                Section("What kind?") {
                    Picker("Kind", selection: $choosenType) {
                        ForEach([QuestType.navigate, QuestType.track, QuestType.collect], id: \.self) { type in
                            Label(type.name, systemImage: type.symbol)
                                .tag(type)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
                
                Section("How long?") {
                    Picker("Duration", selection: $duration) {
                        Text("Short").tag(ChallengeDuration.short)
                        Text("Long").tag(ChallengeDuration.long)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .frame(height: 330)
            .scrollDisabled(true)
            
            
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
