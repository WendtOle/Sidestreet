//
//  ContentView.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData
import GEOSwift
import AVFAudio

struct ContentView: View {
    @ObservedObject var soundController: SoundController
    var selectedQuest: QuestData?
    let createQuest: (QuestType) async -> Void
    let selectQuest: (QuestData) -> Void
    let unselectQuest: (QuestData) -> Void
    let startWalk: () -> Void
    let saveWalk: () -> Void
    let discardWalk: () -> Void
    let recording: Walk?
    let onDeleteWalk: () -> Void
    let heatMap: [(point: GeoPoint, count: Double)]
    
    @State private var cameraPosition: MapCameraPosition =
        .userLocation(followsHeading: false, fallback: .automatic)
    @State private var selectedWalk: Walk?
    
    @State var isHistoryPresented: Bool = false
    @State var isQuestLogPresent: Bool = false
    @State private var showAllWalks = true
    @State private var showSaveConfirmation = false
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Walk.createdAt, order: .reverse)
    private var walks: [Walk]
        
    @Query(sort: \QuestData.createdAt, order: .reverse)
    private var quests: [QuestData]
        
    
    func stopRecording() {
        showSaveConfirmation = true
    }
    
    var body: some View {
        ZStack{
            CustomMap(
                recording: recording,
                heatMap: heatMap,
                cameraPosition: $cameraPosition,
                selectedWalk: selectedWalk,
                showAllWalks: showAllWalks,
                selectedQuest: selectedQuest,
            )
            VStack{
                if let quest = selectedQuest {
                    InformationContainer {
                        QuestInformation(quest: quest)
                        if quest.questReached {
                            Text("Done").font(.headline)
                        }
                    } onClose: {
                        unselectQuest(quest)
                    }
                }
                if let walk = selectedWalk {
                    InformationContainer {
                        WalkInformation(walk: walk)
                    } onClose: {
                        selectedWalk = nil
                    }
                }
                Spacer()
                SideButtons(isHistoryPresented: $isHistoryPresented, isQuestLogPresent: $isQuestLogPresent)
                HStack {
                    RecordingButton(activeWalk: recording, startRecording: startWalk, stopRecording: stopRecording)
                    if recording != nil, selectedQuest?.type == .track {
                        Button {
                            if soundController.isRunning {
                                soundController.stop()
                                return
                            }
                            soundController.start()
                        } label: {
                            
                            Image(systemName: soundController.isRunning ? "speaker.wave.3" : "speaker.slash")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 50, height: 50)
                        
                        }
                        .buttonStyle(.glassProminent)
                        .tint(soundController.isRunning ? Color.accentColor : Color.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .sheet(isPresented: $isHistoryPresented) {
            WalkHistoryView(walks: walks, onSelect: { walk in
                selectedWalk = walk
                if let position = frameRoute(for: walk.coordinates) {
                    withAnimation(
                        .timingCurve(
                            0.2, 0.8,
                            0.2, 1.0,
                            duration: 3
                        )
                    ) {
                        cameraPosition = position
                    }
                }
                }, onDelete: { walk in
                    modelContext.delete(walk)
                    try? modelContext.save()
                    onDeleteWalk()
                }
            )
        .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isQuestLogPresent) {
            QuestLogView(quests: quests, onSelect: { quest in
                if quest.questReached, let walk = quest.walk {
                        selectedWalk = walk
                    } else {
                        selectQuest(quest)
                    }
                }, onDelete: { quest in
                    modelContext.delete(quest)
                    try? modelContext.save()
                }, onCreate: createQuest
            )
        .presentationDetents([.medium, .large])
        }
        .onChange(of: selectedWalk?.id) {
            guard let selectedWalk else {
                return
            }
            cameraPosition = frameRoute(for: selectedWalk.coordinates) ?? cameraPosition
        }
        .confirmationDialog("Save walk?", isPresented: $showSaveConfirmation, titleVisibility: .visible) {
            Button("Save") {
                saveWalk()
            }
            Button("Discard", role: .destructive) {
                discardWalk()
            }
        }
    }
    
}
