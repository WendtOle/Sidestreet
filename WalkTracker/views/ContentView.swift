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
    let createQuest: (QuestType, Bool) -> Void
    let selectQuest: (QuestData) -> Void
    let unselectQuest: () -> Void
    let startWalk: () -> Void
    let saveWalk: () -> Void
    let discardWalk: () -> Void
    let recording: Walk?
    let onDeleteWalk: () -> Void
    let heatMap: [(point: GeoPoint, count: Double)]
    let enableQuestCreation: Bool
    let toggleTrackingSound: () -> Void
    let showWaitingForLocationIndicator: Bool
    
    @State private var cameraPosition: MapCameraPosition =
        .userLocation(followsHeading: false, fallback: .automatic)
    @State private var selectedWalk: Walk?
    
    @State var isHistoryPresented: Bool = false
    @State var isQuestCreationPresented: Bool = false
    @State private var visualizeHeatMap = false
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
                unselectWalk: { selectedWalk = nil },
                visualizeHeatMap: visualizeHeatMap,
                selectedQuest: selectedQuest,
                
            )
            VStack{
                if showWaitingForLocationIndicator {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        
                        Text("Waiting for location update").font(.caption)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 4)
                    .glassEffect(
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                Spacer().frame(height: 50)
                SideButtons(isHistoryPresented: $isHistoryPresented, visualizeHeatMap: $visualizeHeatMap)
                Spacer()
                if let walk = recording {
                    VStack {
                        WalkProgress(
                            createdAt: walk.createdAt,
                            distanceKm: walk.totalDistance / 1_000,
                            accent: .green,
                            softAccent: .blue
                        ) {}
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .padding(.bottom, 6)
                        if let quest = selectedQuest {
                            HStack {
                                Image(systemName: quest.type.symbol)
                                    .frame(width: 35)
                                Text(quest.type.name)
                                Spacer()
                                QuestFactory.progressIndicatorElement(questData: quest)
                                if recording != nil, selectedQuest?.type == .track {
                                    Button {
                                        toggleTrackingSound()
                                    } label: {
                                        
                                        Image(systemName: soundController.isRunning ? "speaker.wave.2" : "speaker.slash")
                                            .font(.system(size: 24, weight: .semibold))
                                            .frame(width: 35, height: 35)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(.blue.opacity(0.25))
                        } else if enableQuestCreation {
                            HStack {
                                Button("Take on a Challenge?") {
                                    isQuestCreationPresented = true
                                }
                            }
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(.blue.opacity(0.25))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .glassEffect(
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                Button {
                    if recording != nil {
                        stopRecording()
                    } else {
                        startWalk()
                    }
                } label: {
                    Image(systemName: recording != nil ? "stop.fill" : "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .frame(width: 72, height: 50)
                    
                }
                .buttonStyle(.glassProminent)
                
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
        .sheet(isPresented: $isQuestCreationPresented) {
            QuestCreationSheet(createQuest: createQuest, isQuestCreationPresented: $isQuestCreationPresented)
                .padding(24)
                .presentationDetents([.fraction(0.7)])
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
