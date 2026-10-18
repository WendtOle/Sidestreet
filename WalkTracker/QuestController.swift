//
//  QuestController.swift
//  WalkTracker
//
//  Created by Ole on 13.10.26.
//

import CoreLocation
import MapKit
import SwiftUI
import Observation
import ActivityKit

protocol Quest {
    var data: QuestData {get set}
    func onLocationUpdate(location: CLLocation, soundController: SoundController) -> Void
    func questMapElements(cameraDistance: Double) -> AnyMapContent
}

@Observable
final class QuestController {
    var activeWalk: Walk?
    private(set) var activeQuest: QuestData?
    var activeActivity: Activity<SessionActivityExtensionAttributes>?
    
    var soundController: SoundController
    private var observationTask: Task<Void, Never>?
    
    init (soundController: SoundController) {
        self.soundController = soundController
        startObserving()
    }
    
    deinit {
        stopObserving()
        observationTask?.cancel()
    }
    
    func setQuest(quest: QuestData) {
        self.activeQuest = quest
        udpateActivity()
    }
    
    func removeQuest() {
        self.activeQuest = nil
        udpateActivity()
    }
    
    func udpateActivity () {
        guard let activity = self.activeActivity, let walk = activeWalk, let quest = activeQuest else { return }
                
        let state = SessionActivityExtensionAttributes.ContentState(
            distanceMeter: walk.totalDistance,
            isTrackingQuestActive: quest.type == .track,
            isTrackingSoundRunning: soundController.isRunning
        )

        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }
    
    func onLocationUpdate(location: CLLocation, distanceToPrev: CLLocationDistance?, durationSincePrev: Double?) {
        if let quest = activeQuest {
            QuestFactory.onLocationUpdate(location: location, questData: quest, soundController: soundController)
        }
        if let walk = activeWalk {
            walk.addPoint(point: location, distanceToPrev: distanceToPrev, timeToPrev: durationSincePrev)
        }
        udpateActivity()
    }
    
    func startObserving() {
        // Prevent multiple observation loops.
        guard observationTask == nil else { return }

        observationTask = Task { @MainActor [weak self, soundController] in
            let changes = Observations {
                soundController.isRunning
            }

            for await isRunning in changes {
                guard !Task.isCancelled else { break }
                guard let self else { break }

                udpateActivity()
            }
        }
    }

    func stopObserving() {
        observationTask?.cancel()
        observationTask = nil
    }
}
