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
    @StateObject private var soundController = SoundController()
    @State private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition =
        .userLocation(followsHeading: false, fallback: .automatic)
    @State private var selectedWalk: Walk?
    @State private var selectedQuest: Quest?
    @State var isHistoryPresented: Bool = false
    @State var isQuestLogPresent: Bool = false
    @State private var showAllWalks = true
    @State private var pendingWalk: Walk?
    @State private var showSaveConfirmation = false
    
    @State private var pendingCompletions: [(walk: Walk, quest: Quest)] = []
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Walk.createdAt, order: .reverse)
    private var walks: [Walk]
    @State private var countedPoints: [(point: GeoPoint, count: Double)] = []
    
    @Query(sort: \Quest.createdAt, order: .reverse)
    private var quests: [Quest]
    
    var openQuests: [Quest] {
        quests.filter { quest in
            let isQuestCompletionPending = pendingCompletions.contains { $0.quest === quest }
            return quest.questReached == false && !isQuestCompletionPending
        }
    }
    
    func createQuest (questType: QuestType) async {
        do {
            let location = try await locationManager.requestCurrentLocation()
            let quest = Quest(referencePoint: location, questType: questType)
            modelContext.insert(quest)
        }
        catch {
            
        }
    }
    
    func fulfillSelectedQuest() {
        guard let quest = selectedQuest,
              let walk = locationManager.currentWalk else {
            return
        }

        pendingCompletions.append((walk: walk, quest: quest))
        soundController.stop()
    }
    
    var body: some View {
        ZStack{
            CustomMap(
                locationManager: $locationManager,
                countedPoints: countedPoints,
                cameraPosition: $cameraPosition,
                selectedWalk: selectedWalk,
                selectedQuest: selectedQuest,
                showAllWalks: showAllWalks,
                quests: quests,
                completedQuests: pendingCompletions.map { $0.quest }
            )
            VStack{
                if let quest = selectedQuest {
                    InformationContainer {
                        QuestInformation(quest: quest)
                        if quest.questReached || pendingCompletions.contains {$0.quest === quest} {
                            Text("Done")
                                .font(.headline)
                        } else if quest.type == .track {
                            Button{
                                Task {
                                    do {
                                        let location = try await locationManager.requestCurrentLocation()
                                        quest.pinnedLocation = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                    } catch {}
                                }
                            } label: {
                                Image(systemName: "pin")
                                .tint(.gray)
                            }
                        }
                    } onClose: {
                        selectedQuest = nil
                        soundController.stop()
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
                    RecordingButton(locationManager: $locationManager, pendingWalk: $pendingWalk, showSaveConfirmation: $showSaveConfirmation, selectedWalk: $selectedWalk)
                    if locationManager.isRecording, selectedQuest?.type == .track {
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
        .onAppear {
            locationManager.requestPermission()
            locationManager.setOnLocationChange(onLocationChange: {location in
                guard let quest = selectedQuest, let walk = locationManager.currentWalk else {
                    return
                }
                let distanceToQuest = location.distance(from: CLLocation(latitude: quest.target.latitude, longitude: quest.target.longitude))
                soundController.setBeepIntervalByDistance(distance: distanceToQuest)
                if isQuestReached(quest: quest, location: location) {
                    fulfillSelectedQuest()
                }
            })
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
                }
            )
        .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isQuestLogPresent) {
            QuestLogView(quests: openQuests, onSelect: { quest in
                    if quest.questReached, let walk = quest.walk {
                        selectedWalk = walk
                    } else {
                        selectedQuest = quest
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
        .onChange(of: Set(walks.map(\.id)), initial: true) {
            countedPoints = calculateHeatmap(walks: walks)
        }
        .confirmationDialog("Save walk?", isPresented: $showSaveConfirmation, titleVisibility: .visible) {
            Button("Save") {
                guard let walk = pendingWalk else { return }
                modelContext.insert(walk)
                
                pendingCompletions.map({completion in
                    if completion.walk === walk {
                        walk.quests.append(completion.quest)
                        completion.quest.walk = walk
                        completion.quest.questReached = true
                    }
                })
                
                pendingCompletions = []
                pendingWalk = nil
                soundController.stop()
            }
            Button("Discard", role: .destructive) {
                pendingCompletions = []
                pendingWalk = nil
                soundController.stop()
            }
        }
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: Walk.self, inMemory: true)
}
