import SwiftUI
import MapKit
import CoreLocation
import SwiftData
import GEOSwift
import AVFAudio

struct RunningChallenge: View {
    let quest: QuestData
    let toggleTrackingSound: () -> Void
    let abandonChallenge: () -> Void
    @ObservedObject var soundController: SoundController
    
    @State var showChallengeExplanation: Bool = false
    
    var body: some View {
        HStack {
            HStack(spacing: 2) {
                Image(systemName: quest.type.symbol)
                    .frame(width: 35)
                Text(quest.type.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Button{
                    showChallengeExplanation = true
                } label: {
                    Image(systemName: "info.circle")
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer()
            
            if quest.type != .track {
                QuestFactory.progressIndicatorElement(questData: quest)
            }
            if quest.type == .track {
                Button {
                    toggleTrackingSound()
                } label: {
                    Image(systemName: soundController.isRunning ? "speaker.wave.2" : "speaker.slash")
                        .font(.system(size: 24, weight: .semibold))
                        .frame(width: 35, height: 35)
                }
                .padding(6)
                .background(
                    Color("AccentColor").opacity(0.15),
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }
            Menu {
                Button("Abandon") {
                    abandonChallenge()
                }
                Button("Explain") {
                    showChallengeExplanation = true
                }
            } label: {
                Image(systemName: "ellipsis")
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .adaptiveSheet(isPresent: $showChallengeExplanation, title: quest.type.longName)  {
            VStack(alignment: .leading, spacing: 12) {
                Text(quest.type.helpDescription)
                    .font(.callout)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                Image(quest.type.helpImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                
            }
        }
    }
    
}
