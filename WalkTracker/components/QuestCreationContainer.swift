import SwiftUI

struct QuestCreationContainer: View {
    let createQuest: (QuestType, Bool) -> Void
    @State var choosenType: QuestType? = nil
    @Binding var dismissedChallengeCreation: Bool
    
    func onClose () {
        dismissedChallengeCreation = true
    }
    
    var body: some View {
        if choosenType == nil {
            VStack(spacing: 15) {
                HStack {
                    Text("Take on a Challenge?").font(.headline)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                
                HStack(spacing: 20) {
                    ForEach(QuestType.allCases, id: \.self) { type in
                        Button {
                            choosenType = type
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: type.symbol)
                                    .font(.system(size: 28))
                                Text("\(type.name)")
                                    .font(.subheadline)
                            }
                        }.disabled(type == .orbit)
                    }
                }
                
            }
            .padding()
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 16)
            )
            .padding(.horizontal)
        } else if let type = choosenType{
            VStack(spacing: 15) {
                HStack {
                    Text("How much time do you have?").font(.headline)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                
                HStack(spacing: 40) {
                    Button {
                        createQuest(type, true)
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "30.arrow.trianglehead.clockwise")
                                .font(.system(size: 28))
                            Text("a little")
                                .font(.subheadline)
                        }
                    }
                    Button {
                        createQuest(type, false)
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "60.arrow.trianglehead.clockwise")
                                .font(.system(size: 28))
                            Text("a lot")
                                .font(.subheadline)
                        }
                    }
                }
                
            }
            .padding()
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 16)
            )
            .padding(.horizontal)
        }
    }
}
