//
//  QuestFactory.swift
//  WalkTracker
//
//  Created by Ole on 14.10.26.
//

import MapKit
import SwiftUI

enum QuestFactory {
    static func make(referencePoint: CLLocation, questType: QuestType, heatMap: [(point: GeoPoint, count: Double)], smallVariant: Bool) -> QuestData {
        let minDistance = smallVariant ? 100.0 : 300.0
        let maxDistance = smallVariant ? 600.0 : 1200.0
        switch questType {
        case .collect :
            var max = 0.0
            let pointAmount = smallVariant ? 40 : 100
            let preCoins = (0..<pointAmount).map { _ in
                let coinDistance = Double.random(in: minDistance...maxDistance)
                let rawCoinLocation = getQuestTarget(startingPoint: referencePoint, distance: coinDistance)
                let binnedLocation = getBinnedCoordinates(rawCoinLocation)
                let value = heatMap.first {$0.point.latitude == binnedLocation[0] && $0.point.longitude == binnedLocation[1]}?.count ?? 0
                if value > max {
                    max = value
                }
                return Target(point: rawCoinLocation, value: value)
            }
            
            let potentialCoins = (preCoins).map { coin in
                let value = max > 0 ? 1 - (coin.value / max) : 1
                return Target(point: coin.point, value: value)
            }
            let targets = potentialCoins.filter { $0.value > 0.001 }
            return QuestData(targets: targets, type: questType)
        default:
            let distance = Double.random(in: minDistance...maxDistance)
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
        case .collect:
            let toCollect = questData.targets.map { target in
                let distance = location.distance(from: CLLocation(latitude: target.point.latitude, longitude: target.point.longitude))
                if distance > 30.0 {
                    return target
                }
                return Target(point: target.point, value: target.value, collected: true)
            }
            questData.targets = toCollect
            if toCollect.allSatisfy({ $0.collected }) {
                questData.questReached = true
            }
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
        case .navigate:
            let center = CLLocationCoordinate2D(latitude: questData.targets[0].point.latitude, longitude: questData.targets[0].point.longitude)
            return AnyMapContent(Marker("", systemImage: questData.type.symbol, coordinate: center).tint(color))
        case .collect:
            let remainingTargets = questData.targets.enumerated().filter { !$0.element.collected }
            return AnyMapContent(
                ForEach(remainingTargets, id: \.offset) { target in
                    let item = target.element
                    let coordinate = CLLocationCoordinate2D(
                        latitude: item.point.latitude,
                        longitude: item.point.longitude
                    )
                    let maxRadius = 19.0
                    let minRadius = 0.0
                    let radius = Double(item.value) * (maxRadius - minRadius)
                    MapCircle(
                        center: coordinate,
                        radius: radius
                    )
                    .foregroundStyle(.yellow)
                    
                    /*
                     Annotation("", coordinate: coordinate, anchor: .center) {
                     Text("\(Int(item.value * 100))")
                     .font(.system(size: 10, weight: .bold))
                     .foregroundStyle(.blue)
                     .fixedSize()
                     }
                     */
                }
                )
        default:
            return AnyMapContent(EmptyMapContent())
        }
    }
    
    @ViewBuilder
    static func progressIndicatorElement(questData: QuestData) -> some View {
        switch questData.type {
        case .collect:
            let score = questData.targets.reduce(0) {accumulated, target in
                if target.collected {
                    return accumulated + target.collectionPoints
                }
                return accumulated
            }
            Text("\(score) points").font(.headline)
        default:
            if questData.questReached {
                Text("Done").font(.headline)
            }
        }
    }
}
