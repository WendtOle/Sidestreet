import SwiftUI
import MapKit
import CoreLocation
import SwiftData
import GEOSwift
import AVFAudio

struct ContentView: View {
    var isLocationServiceEnabled: Bool
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
    let isLocationUpdatePending: Bool
    
    @Namespace private var mapScope
    
    @State private var cameraPosition: MapCameraPosition =
        .userLocation(followsHeading: false, fallback: .automatic)
    @State private var selectedWalk: Walk?
    
    @State var isQuestCreationPresented: Bool = false
    @State private var visualizeHeatMap = false
    @State private var showSaveConfirmation = false
    @State private var showRecentlySavedWalk = false
    @State var mapStyle: Style = .standard
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Walk.createdAt, order: .reverse)
    private var walks: [Walk]
        
    @Query(sort: \QuestData.createdAt, order: .reverse)
    private var quests: [QuestData]
    
    @Query(filter: #Predicate<SettingsData> { $0.key == "app" })
    private var settingsRecords: [SettingsData]
        
    
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
                isLocationServiceEnabled: isLocationServiceEnabled,
                mapScope: mapScope,
                mapStyle: mapStyle
            )
            VStack{
                LocationEnabledAlert(
                    isLocationServiceEnabled: isLocationServiceEnabled,
                    isRecording: recording != nil
                )
                LocationUpdatePendingAlert(
                    isLocationUpdatePending: isLocationUpdatePending
                )
                HStack {
                    Spacer()
                    MapScaleView(scope: mapScope)
                    Spacer()
                }
                .frame(height: 30)
                Spacer()
                HStack(alignment: .bottom){
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
                    Spacer()
                    VStack {
                        if isLocationServiceEnabled {
                            MapCompass(scope: mapScope)
                                .mapControlVisibility(.visible)
                        }
                        Button {} label: {
                            VStack (spacing: 16){
                                MapStyleSelector(mapCameraPosition: cameraPosition, style: $mapStyle, showsHeatMap: $visualizeHeatMap)
                                Button {
                                    withAnimation {
                                        cameraPosition = .userLocation(
                                            followsHeading: false,
                                            fallback: .automatic
                                        )
                                    }
                                } label: {
                                    Image(systemName: cameraPosition.followsUserLocation
                                          ? "location.fill"
                                          : "location")
                                    .font(.system(size: 20))
                                    .tint(.primary)
                                }
                                .disabled(!isLocationServiceEnabled)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.glass)
                    }

                }
                if let walk = recording {
                    VStack {
                        WalkProgress(
                            createdAt: walk.createdAt,
                            distanceKm: walk.totalDistance / 1_000
                        ) {}
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .padding(.bottom, 6)
                        if let quest = selectedQuest {
                            Divider()
                            HStack {
                                HStack(spacing: 2) {
                                    Image(systemName: quest.type.symbol)
                                        .frame(width: 35)
                                    Text(quest.type.name)
                                    QuestTypeExplanation(type: quest.type)
                                }
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
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                            .frame(maxWidth: .infinity)
                        } else if enableQuestCreation {
                            Divider()
                            HStack {
                                Button("Take on a Challenge?") {
                                    isQuestCreationPresented = true
                                }
                            }
                            .padding(.bottom, 12)
                            .frame(maxWidth: .infinity)
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
                .disabled(recording == nil && !isLocationServiceEnabled)
            }
            .padding(.horizontal)
            .overlay(alignment: .topLeading) {
                AppMenu()
            }
        }
        .mapScope(mapScope)
        .adaptiveSheet(isPresent: $isQuestCreationPresented, title: "Find your challenge", exitTitle: "Cancel"){
            QuestCreationSheet(createQuest: createQuest, isQuestCreationPresented: $isQuestCreationPresented)
        }
        .onChange(of: selectedWalk?.id) {
            guard let selectedWalk else {
                return
            }
            cameraPosition = frameRoute(for: selectedWalk.coordinates) ?? cameraPosition
        }
        .adaptiveSheet(isPresent: $showRecentlySavedWalk) {
            if let walk = walks.first {
                WalkSummary(walk: walk)
            }
        }
        .confirmationDialog("Finish recording?", isPresented: $showSaveConfirmation, titleVisibility: .visible) {
            if let settings = settingsRecords.first {
                Button(settings.enableDiscardingWalks ? "Save" : "Finish", role: .confirm) {
                    saveWalk()
                    showRecentlySavedWalk = true
                }
                if settings.enableDiscardingWalks {
                    Button("Discard", role: .destructive) {
                        discardWalk()
                    }
                }
            }
            Button("Continue", role: .close) {
                showSaveConfirmation = false
            }
        }
    }
    
}
