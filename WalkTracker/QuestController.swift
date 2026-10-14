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

protocol Quest {
    var data: QuestData {get set}
    func onLocationUpdate(location: CLLocation, soundController: SoundController) -> Void
    func questMapElements(cameraDistance: Double) -> AnyMapContent
}

@Observable
final class QuestController {
    var activeWalk: Walk?
    var activeQuest: QuestData?
    var soundController: SoundController
    
    
    init (soundController: SoundController) {
        self.soundController = soundController
    }
    
    func onLocationUpdate(location: CLLocation, distanceToPrev: CLLocationDistance?, durationSincePrev: Double?) {
        if let quest = activeQuest {
            QuestFactory.onLocationUpdate(location: location, questData: quest, soundController: soundController)
        }
        if let walk = activeWalk {
            walk.addPoint(point: location, distanceToPrev: distanceToPrev, timeToPrev: durationSincePrev)
        }
    }
}
