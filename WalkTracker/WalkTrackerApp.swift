import SwiftUI
import SwiftData
import ActivityKit
import AppIntents

class AppDelegate: NSObject, UIApplicationDelegate {
    var onTerminate: (() -> Void)?
    
    func applicationWillTerminate(_ application: UIApplication) {
        onTerminate?()
        let completion = DispatchSemaphore(value: 0)

        Task.detached {
            defer { completion.signal() }
            for activity in Activity<SessionActivityExtensionAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }

        let result = completion.wait(timeout: .now() + 2)

        if result == .timedOut {
            print("Activity cleanup timed out")
        }
    }
}

@main
struct WalkTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let container: ModelContainer
    
    @State private var soundController: SoundController
    @State private var questController: QuestController
    @State var locationManager: LocationManager
    
    @State private var heatMap: [(point: GeoPoint, count: Double)]
    @State private var walkReferencePoint: CLLocation?
    
    @State var activity: Activity<SessionActivityExtensionAttributes>?
    
    init() {
        do {
            let modelContainer = try ModelContainer(for: QuestData.self, Walk.self, SettingsData.self)
            container = modelContainer
            try SettingsData.createIfNeeded(in: modelContainer.mainContext)
            
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
    
    func stopActivitySession () async {
        guard let activity = self.activity else { return }
        questController.activeActivity = nil
        await activity.end(
            activity.content,
            dismissalPolicy: .immediate
        )
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
        guard let walk = questController.activeWalk, let point = walk.coordinates.last else { return }
        let quest = QuestFactory.make(referencePoint: CLLocation(latitude: point.latitude, longitude: point.longitude), questType: questType, heatMap: heatMap, smallVariant: smallVariant)
        let context = container.mainContext
        context.insert(quest)
        questController.setQuest(quest: quest)
    }
    
    func reset () {
        walkReferencePoint = nil
        locationManager.stopRecording()
        soundController.stop()
        self.questController.activeWalk = nil
        Task {
            await stopActivitySession()
        }
    }
    
    func startWalk() {
        let newWalk = Walk()
        self.questController.activeWalk = newWalk
        locationManager.startRecording()
        startActivitySession(createdAt: newWalk.createdAt)
    }
    
    func saveWalk() {
        guard let walk = self.questController.activeWalk else { return }
        
        // persist walk
        let context = container.mainContext
        
        context.insert(walk)
        
        if let quest = self.questController.activeQuest {
            walk.quests.append(quest)
        }
        
        do {
            try context.save()
            print("Walk saved to persistent storage")
        } catch {
            print("Could not save walk: \(error)")
            return
        }
        
        if self.questController.activeQuest != nil {
            questController.removeQuest()
        }
        
        reset()
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
                isLocationServiceEnabled: locationManager.servicesEnabled ?? true,
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
                enableQuestCreation: questController.activeWalk?.coordinates.isEmpty == false && questController.activeQuest == nil,
                toggleTrackingSound: toggleTrackingSound,
                isLocationUpdatePending: questController.activeWalk?.coordinates.isEmpty == true,
            )
            .onAppear {
                locationManager.requestPermission()
                appDelegate.onTerminate = {
                    saveWalk()
                }
            }
        }
        .modelContainer(container)
    }
}
