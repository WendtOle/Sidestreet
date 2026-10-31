import SwiftUI

enum ChallengeDuration: Hashable {
    case short
    case long
}

enum ChallengeCreationSteps {
    case type
    case duration
    case notice
    
    var number: String {
        switch self {
        case .type:
            return "1"
        case .duration:
            return "2"
        case .notice:
            return "3"
        }
    }
    
    var name: String {
        switch self {
        case .type:
            return "Challenge type"
        case .duration:
            return "Challenge duration"
        case .notice:
            return "Safety notice"
        }
    }
    
    var next: ChallengeCreationSteps? {
        switch self {
        case .type:
            return .duration
        case .duration:
            return .notice
        default:
            return nil
        }
    }
    
    var previous: ChallengeCreationSteps? {
        switch self {
        case .notice:
            return .duration
        case .duration:
            return .type
        default:
            return nil
        }
    }
}

struct QuestCreationSheet: View {
    let createQuest: (QuestType, Bool) -> Void
    @State var step: ChallengeCreationSteps = .type
    @State var choosenType: QuestType = QuestType.navigate
    @State var duration: ChallengeDuration = ChallengeDuration.long
    @State var noticeAccepted: Bool = false
    @Binding var isQuestCreationPresented: Bool

    var body: some View {
        SheetWrapper(isPresented: $isQuestCreationPresented, title: "Find your challenge", exitTitle: "Cancel", onPrevious: step.previous != nil ? {
            if let previous = step.previous {
                step = previous
            }
        }: nil) {
            VStack(spacing: 8) {
                Text("\(step.number) of 3 - \(step.name)").font(.callout.weight(.light))
                Divider()
                switch step {
                case .type:
                    TypeView(type: $choosenType).padding()
                    Spacer()
                    if let nextStep = step.next {
                        CustomButton(onClick: {
                            step = nextStep
                        }, text: "Continue")
                    }
                case .duration:
                    DurationView(duration: $duration).padding()
                    Spacer()
                    if let nextStep = step.next {
                        CustomButton(onClick: {
                            step = nextStep
                        }, text: "Continue")
                    }
                case .notice:
                    NotiveView(accepted: $noticeAccepted).padding()
                    Spacer()
                    CustomButton(onClick: {
                        createQuest(choosenType, duration == ChallengeDuration.short)
                        isQuestCreationPresented = false
                    }, text: "Start Challenge", disabled: !noticeAccepted)
                }
                                    
            }
        }
    }
}

struct CustomButton: View {
    var onClick: () -> Void
    var text: String
    var disabled: Bool?
    
    var body: some View {
        Button {
            onClick()
        } label: {
            Text(text)
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.glassProminent)
        .disabled(disabled ?? false)
    }
}

struct TypeView: View {
    @Binding var type: QuestType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("What kind?").font(.headline)
                Spacer()
            }
            Picker("Challenge type", selection: $type) {
                ForEach(QuestType.allCases, id: \.self) { type in
                    Label(type.name, systemImage: type.symbol)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            VStack(alignment: .leading, spacing: 12) {
                Image(type.helpImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                    .frame(maxWidth: .infinity)
                Text(type.helpDescription)
                    .font(.subheadline)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
    }
}

struct DurationView: View {
    @Binding var duration: ChallengeDuration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How long?").font(.headline.bold())
            Text("Short challenges keep you close to your starting point. Long challenges take you farther away.").font(.subheadline)
            Picker("Duration", selection: $duration) {
                Text("Short").tag(ChallengeDuration.short)
                Text("Long").tag(ChallengeDuration.long)
            }
            .pickerStyle(.segmented)
        }
    }
}

struct NotiveView: View {
    @Binding var accepted: Bool
    var body: some View {
        VStack(spacing: 16) {
            Text("""
            Challenge targets are generated randomly. Sidestreet does not verify whether they are accessible, open to the public, or safe to reach.
             
             Use your judgment and follow local signs and rules. Stay on safe, publicly accessible paths. Never enter private property, restricted areas, water, or dangerous terrain to reach a target.
            
             You decide whether to continue. Stop the challenge if a target cannot be reached safely. No challenge is worth risking your safety or anyone else’s.
            """).font(.body)
            HStack {
                Toggle("I understand", isOn: $accepted)
                    .toggleStyle(.switch)
                    .tint(.blue)
            }
        }
    }
}
