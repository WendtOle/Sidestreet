//
//  WalkTrackerApp.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI
import SwiftData

@main
struct WalkTrackerApp: App {
    private let container: ModelContainer
    
    @State private var soundController: SoundController
    @State private var questController: QuestController
    @State var locationManager: LocationManager
    
    @State private var heatMap: [(point: GeoPoint, count: Double)]
    
    init() {
        do {
            let modelContainer = try ModelContainer(for: QuestData.self, Walk.self)
            container = modelContainer
            
            let walks = try modelContainer.mainContext.fetch(
                FetchDescriptor<Walk>()
            )
            _heatMap = State(
                initialValue: calculateHeatmap(walks: walks)
            )
        } catch {
            fatalError("Could not initialize app data: \(error)")
        }
        let soundController = SoundController()
        self.soundController = soundController
        let questController = QuestController(soundController: soundController)
        self.questController = questController
        locationManager = LocationManager(onLocationUpdate: questController.onLocationUpdate)
    }
    
    @MainActor
    func refreshHeatmap() {
        do {
            let walks = try container.mainContext.fetch(FetchDescriptor<Walk>())
            heatMap = calculateHeatmap(walks: walks)
        } catch {
            fatalError("could not refresh heatmap \(error)")
        }
    }
    
    func createQuest (questType: QuestType) async {
        do {
            let location = try await locationManager.requestCurrentLocation()
            let quest = QuestFactory.make(referencePoint: location, questType: questType, heatMap: heatMap)
            let context = container.mainContext
            context.insert(quest)
        } catch {
            fatalError("could not create quest \(error)")
        }
    }
    
    func startWalk() {
        let newWalk = Walk()
        self.questController.activeWalk = newWalk
        locationManager.startRecording()
    }
    
    func saveWalk() {
        locationManager.stopRecording()
        guard let walk = self.questController.activeWalk else { return }
        
        // persist walk
        let context = container.mainContext
        context.insert(walk)
        
        // if quest is reached connect quest to walk
        if let quest = self.questController.activeQuest, quest.questReached {
            walk.quests.append(quest)
            self.questController.activeQuest = nil
        }
        self.questController.activeWalk = nil
        refreshHeatmap()
    }
    
    func discardWalk() {
        locationManager.stopRecording()
        self.questController.activeWalk = nil
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                soundController: soundController,
                selectedQuest: questController.activeQuest,
                createQuest: createQuest,
                selectQuest: {quest in
                    questController.activeQuest = quest
                },
                unselectQuest: {_ in
                    questController.activeQuest = nil
                },
                startWalk: startWalk,
                saveWalk: saveWalk,
                discardWalk: discardWalk,
                recording: questController.activeWalk,
                onDeleteWalk: refreshHeatmap,
                heatMap: heatMap
            )
            .onAppear {
                locationManager.requestPermission()
            }
        }
        .modelContainer(container)
    }
}
