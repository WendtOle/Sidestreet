//
//  SideButtons.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//

import SwiftUI
import Combine

struct SideButtons: View {
    @Binding var echoMode: Bool
    @ObservedObject var soundController: SoundController
    @Binding var fogModeActive: Bool
    @Binding var isHistoryPresented: Bool
    @Binding var isQuestLogPresent: Bool
    @State var creatingQuest = false
    var createQuest: () async -> Void
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Button {
                    echoMode.toggle()
                } label: {
                    Image(systemName: echoMode ? "ear" : "eye")
                        .font(.system(size: 18))
                }
                .buttonStyle(.glass)
                
                Button {
                    if soundController.isRunning {
                        soundController.stop()
                        return
                    }
                    soundController.start()
                } label: {
                    Image(systemName: soundController.isRunning ? "speaker.wave.3" : "speaker.slash")
                        .font(.system(size: 18))
                }
                .buttonStyle(.glass)
                
                Button {
                    fogModeActive.toggle()
                } label: {
                    Image(systemName: fogModeActive ? "moon" : "sun.max")
                        .font(.system(size: 18))
                }
                .buttonStyle(.glass)
                
                Button {
                    isQuestLogPresent = true
                    /*Task {
                        creatingQuest = true
                        await createQuest()
                        creatingQuest = false
                    }*/
                } label: {
                    Image(systemName: "flag.2.crossed")
                        .font(.system(size: 18))
                }
                .buttonStyle(.glass)
                
                Button {
                    isHistoryPresented = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 18))
                }
                .buttonStyle(.glass)
            }
        }
    }
}

