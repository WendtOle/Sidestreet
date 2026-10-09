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
    @State private var fogModeActive = false
    @State private var echoMode = false
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Walk.createdAt, order: .reverse)
    private var walks: [Walk]
    
    @Query(sort: \Quest.createdAt, order: .reverse)
    private var quests: [Quest]
    
    func createQuest () async {
        do {
            let location = try await locationManager.requestCurrentLocation()
            let quest = Quest(referencePoint: location)
            modelContext.insert(quest)
        }
        catch {
            
        }
    }
    
    var body: some View {
        ZStack{
            CustomMap(locationManager: $locationManager, walks: walks, fogModeActive: fogModeActive, cameraPosition: $cameraPosition, selectedWalk: selectedWalk, selectedQuest: selectedQuest, showAllWalks: showAllWalks, echoMode: echoMode, quests: quests)
            VStack{
                if let quest = selectedQuest {
                    InformationContainer(entity: .quest(quest)) {
                        selectedQuest = nil
                    }
                }
                if let walk = selectedWalk {
                    InformationContainer(entity: .walk(walk)) {
                        selectedWalk = nil
                    }
                }
                Spacer()
                SideButtons(echoMode: $echoMode, soundController: soundController, fogModeActive: $fogModeActive, isHistoryPresented: $isHistoryPresented, isQuestLogPresent: $isQuestLogPresent, createQuest: createQuest)
                RecordingButton(locationManager: $locationManager, pendingWalk: $pendingWalk, showSaveConfirmation: $showSaveConfirmation, selectedWalk: $selectedWalk)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onAppear {
            locationManager.requestPermission()
            locationManager.setOnChange(onChange: soundController.setBeepIntervalByDistance)
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
            QuestLogView(quests: quests, onSelect: { quest in
                selectedQuest = quest
                }, onDelete: { quest in
                    modelContext.delete(quest)
                    try? modelContext.save()
                }
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
                guard let walk = pendingWalk else { return }
                modelContext.insert(walk)
                pendingWalk = nil
            }
            Button("Discard", role: .destructive) {
                pendingWalk = nil
            }
        }
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: Walk.self, inMemory: true)
}
