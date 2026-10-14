//
//  QuestFactory.swift
//  WalkTracker
//
//  Created by Ole on 14.10.26.
//

import MapKit
import SwiftUI

enum QuestFactory {
    static func make(referencePoint: CLLocation, questType: QuestType) -> QuestData {
        switch questType {
        default:
            let distance = Double.random(in: questType.distance.min...questType.distance.max)
            let target = getQuestTarget(startingPoint: referencePoint, distance: distance)
            return QuestData(targets: [Target(point: target, value: 30.0)], type: questType)
        }
    }
    
    static func onLocationUpdate(location: CLLocation, questData: QuestData, soundController: SoundController) {
        guard let firstTarget = questData.targets.first else { return }
        
        let distanceToFirst = location.distance(from: CLLocation(latitude: firstTarget.point.latitude, longitude: firstTarget.point.longitude))

        switch questData.type {
        case .track:
            soundController.setBeepIntervalByDistance(distance: distanceToFirst)
            if distanceToFirst <= firstTarget.value {
                questData.questReached = true
                soundController.stop()
            }
            return
        default:
            if distanceToFirst <= firstTarget.value {
                questData.questReached = true
            }
            return
        }
    }
    
    static func mapElements (questData: QuestData) -> AnyMapContent  {
        let color = questData.questReached ? Color.orange : .green
        
        switch questData.type {
        case .track:
            if !questData.questReached {
                return AnyMapContent(EmptyMapContent())
            }
            return AnyMapContent(
                Marker(
                    "",
                    systemImage: questData.type.symbol,
                    coordinate: CLLocationCoordinate2D(
                        latitude: questData.targets[0].point.latitude,
                        longitude: questData.targets[0].point.longitude
                    )
                )
                .tint(color)
            )
        case .navigate, .navigateClose:
            let center = CLLocationCoordinate2D(latitude: questData.targets[0].point.latitude, longitude: questData.targets[0].point.longitude)
            return AnyMapContent(Marker("", systemImage: questData.type.symbol, coordinate: center).tint(color))
        default:
            return AnyMapContent(EmptyMapContent())
        }
    }
}
