//
//  WalkTrackerApp.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI
import SwiftData
import ActivityKit
import AppIntents

@main
struct WalkTrackerApp: App {
    private let container: ModelContainer
    
    @State private var soundController: SoundController
    @State private var questController: QuestController
    @State var locationManager: LocationManager
    
    @State private var heatMap: [(point: GeoPoint, count: Double)]
    @State private var walkReferencePoint: CLLocation?
    
    @State var activity: Activity<SessionActivityExtensionAttributes>?
    
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
        AppDependencyManager.shared.add(dependency: soundController)
        let questController = QuestController(soundController: soundController)
        self.questController = questController
        locationManager = LocationManager(onLocationUpdate: questController.onLocationUpdate)
    }
    
    func startActivitySession (createdAt: Date) {
        do {
            let activity = try Activity<SessionActivityExtensionAttributes>.request(
                attributes: .init(name: "Test-Session", createdAt: createdAt),
                content: ActivityContent(
                    state: .init(distanceMeter: 0.0,
                                 isTrackingQuestActive: false,
                                 isTrackingSoundRunning: soundController.isRunning
                                ),
                    staleDate: nil
                ),
                pushType: nil
            )
            self.activity = activity
            questController.activeActivity = activity
        } catch {
            print("Live Activity konnte nicht starten:", error)
        }
    }
    
    func stopActivitySession () {
        guard let activity = self.activity else { return }
        questController.activeActivity = nil
        Task {
            await activity.end(
                activity.content,
                dismissalPolicy: .immediate
            )
        }
        
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
    
    func createQuest (questType: QuestType, smallVariant: Bool) {
        guard let point = walkReferencePoint else { return }
        let quest = QuestFactory.make(referencePoint: point, questType: questType, heatMap: heatMap, smallVariant: smallVariant)
        let context = container.mainContext
        context.insert(quest)
        questController.setQuest(quest: quest)
    }
    
    func reset () {
        walkReferencePoint = nil
        locationManager.stopRecording()
        self.questController.activeWalk = nil
        stopActivitySession()
    }
    
    func startWalk() {
        let newWalk = Walk()
        self.questController.activeWalk = newWalk
        locationManager.startRecording()
        startActivitySession(createdAt: newWalk.createdAt)
        Task {
            do {
                let location = try await locationManager.requestCurrentLocation()
                walkReferencePoint = location
            } catch {
                fatalError("could not find quest reference point \(error)")
            }
        }
        
    }
    
    func saveWalk() {
        guard let walk = self.questController.activeWalk else { return }
        reset()
        
        // persist walk
        let context = container.mainContext
        context.insert(walk)
        
        // if quest is reached connect quest to walk
        if let quest = self.questController.activeQuest, quest.questReached {
            walk.quests.append(quest)
            questController.removeQuest()
        }
        self.questController.activeWalk = nil
        refreshHeatmap()
    }
    
    func discardWalk() {
        reset()
        self.questController.removeQuest()
    }
    
    func toggleTrackingSound() {
        if soundController.isRunning {
            soundController.stop()
        } else {
            soundController.start()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                soundController: soundController,
                selectedQuest: questController.activeQuest,
                createQuest: createQuest,
                selectQuest: {quest in
                    questController.setQuest(quest: quest)
                },
                unselectQuest: questController.removeQuest,
                startWalk: startWalk,
                saveWalk: saveWalk,
                discardWalk: discardWalk,
                recording: questController.activeWalk,
                onDeleteWalk: refreshHeatmap,
                heatMap: heatMap,
                enableQuestCreation: walkReferencePoint != nil && questController.activeQuest == nil,
                toggleTrackingSound: toggleTrackingSound
            )
            .onAppear {
                locationManager.requestPermission()
            }
        }
        .modelContainer(container)
    }
}
