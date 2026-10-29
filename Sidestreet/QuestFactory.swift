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
                let coinDistance = Double.random(in: 100.0...maxDistance)
                let rawCoinLocation = getQuestTarget(startingPoint: referencePoint, distance: coinDistance)
                let binnedLocation = getBinnedCoordinates(rawCoinLocation)
                let value = heatMap.first {$0.point.latitude == binnedLocation[0] && $0.point.longitude == binnedLocation[1]}?.count ?? 0
                if value > max {
                    max = value
                }
                return Target(point: rawCoinLocation, value: value)
            }
            
            let potentialCoins = (preCoins).map { coin in
                let pureValue = max > 0 ? 1 - (coin.value / max) : 1
                let value = pureValue == 1 ? 10 : (pureValue * pureValue * pureValue * 5)
                return Target(point: coin.point, value: Double(Int(value)))
            }
            let targets = potentialCoins.filter { $0.value > 0 }
            let sum = targets.reduce(0) {acc, curr in
                return acc + curr.value
            }
            print("\(sum) - \(targets.count) - \(sum / Double(targets.count))")
            return QuestData(targets: targets, type: questType, targetScore: smallVariant ? 50 : 80)
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
            markClosest(distance: distanceToFirst, currentLocation: location, questData: questData)
            
            let DISTANCE = 20.0
            if distanceToFirst <= DISTANCE {
                questData.questReached = true
                soundController.stop()
            }
            soundController.setBeepIntervalByDistance(distance: distanceToFirst)
            return
        case .collect:
            let DISTANCE = 10.0
            let updatedTargets = questData.targets.map { target in
                let distance = location.distance(from: CLLocation(latitude: target.point.latitude, longitude: target.point.longitude))
                if distance > DISTANCE {
                    return target
                }
                return Target(point: target.point, value: target.value, collected: true)
            }
            questData.targets = updatedTargets
            let score = updatedTargets.reduce(0) {acc, target in
                if target.collected {
                    return acc + target.value
                }
                return acc
            }
            if let toReachScore = questData.targetScore, score >= Double(toReachScore) {
                questData.questReached = true
            }
        case .navigate:
            let DISTANCE = 20.0
            if distanceToFirst <= DISTANCE {
                questData.questReached = true
            }
            markClosest(distance: distanceToFirst, currentLocation: location, questData: questData)
            return
        }
    }
    
    static func mapElements (questData: QuestData, walkFinished: Bool) -> AnyMapContent  {
        let color = questData.questReached ? Color.orange : walkFinished ? .red : .green
        guard let firstTarget = questData.targets.first else {
            return AnyMapContent(EmptyMapContent())
        }
        let firstTargetPoint = CLLocationCoordinate2D(
            latitude: firstTarget.point.latitude,
            longitude: firstTarget.point.longitude
        )
        
        switch questData.type {
        case .track:
            if !questData.questReached && !walkFinished {
                return AnyMapContent(EmptyMapContent())
            }
            return AnyMapContent(
                Group {
                    Marker("", systemImage: questData.type.symbol, coordinate: firstTargetPoint)
                        .tint(color)
                    drawClosestPoint(questData: questData, color: walkFinished ? .orange : .blue)
                }
            )
        case .navigate:
            return AnyMapContent(
                Group {
                    Marker("", systemImage: questData.type.symbol, coordinate: firstTargetPoint)
                        .tint(color)
                    drawClosestPoint(questData: questData, color: walkFinished ? .orange : .blue)
                }
            )
        case .collect:
            let targetsToDraw = questData.targets.enumerated().filter { walkFinished ? $0.element.collected : !$0.element.collected }
            return AnyMapContent(
                ForEach(targetsToDraw, id: \.offset) { target in
                    let item = target.element
                    drawPoint(target: item)
                })
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
                    return accumulated + target.value
                }
                return accumulated
            }
            if let toReachScore = questData.targetScore {
                HStack {
                    Text("\(Int(score)) / \(toReachScore) pts")
                }
            }
        default:
            Text("")
        }
    }
}

func markClosest(distance: CLLocationDistance, currentLocation: CLLocation, questData: QuestData) {
    let SCORE_DISTANCE = 100.0
    if distance < SCORE_DISTANCE {
        let newClosest = Target(
            point: GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude),
            value: distance
        )
        if let nearestReachedPoint = questData.targets.last, questData.targets.count == 2 {
            if nearestReachedPoint.value > distance {
                questData.targets[1] = newClosest
            }
        } else {
            questData.targets.append(newClosest)
        }
    }
}

@MapContentBuilder
func drawClosestPoint(questData: QuestData, color: Color) -> some MapContent {
    if questData.targets.count > 1, let nearestReachedPoint = questData.targets.last {
        let nearestReachedPointCoordinate = CLLocationCoordinate2D(latitude: nearestReachedPoint.point.latitude, longitude: nearestReachedPoint.point.longitude)
        Annotation("Price", coordinate: nearestReachedPointCoordinate, anchor: .bottom) {
            Text("\(Int(nearestReachedPoint.value)) m away")
                .font(.caption.bold())
                .padding(6)
                .glassEffect()
            Image(systemName: "mappin")
                .font(.system(size: 24))
                .foregroundStyle(color)
        }
        .annotationTitles(.hidden)
    }
}

func drawPoint(target: Target) -> some MapContent {
    let coordinate = CLLocationCoordinate2D(
        latitude: target.point.latitude,
        longitude: target.point.longitude
    )
    let valueToPrint = "\(Int(target.value)) pt\(target.value > 1 ? "s": "")"

    return Annotation("Price", coordinate: coordinate, anchor: .bottom) {
        Text(valueToPrint)
            .font(.caption.bold())
            .padding(6)
            .glassEffect()
        VStack(spacing: 4) {
            Image(systemName: "mappin")
                .font(.system(size: 24))
                .foregroundStyle(.blue)
        }
    }
    .annotationTitles(.hidden)
}
