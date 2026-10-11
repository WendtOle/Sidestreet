//
//  Map.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//
import SwiftUI
import MapKit
import CoreLocation


struct CustomMap: View {
    @Binding var locationManager: LocationManager
    var walks: [Walk]
    var fogModeActive: Bool
    @Binding var cameraPosition: MapCameraPosition
    @State private var cameraDistance: Double = 10_000
    var selectedWalk: Walk?
    var selectedQuest: Quest?
    var showAllWalks: Bool
    var quests: [Quest]
    
    var body: some View {
        Map(position: $cameraPosition){
            if fogModeActive {
                MapPolygon(
                    FogPolygonBuilder.makeFogPolygon(
                        walks: walks,
                        revealRadius: 50
                    )
                )
                .foregroundStyle(.white.opacity(0.95))
                .mapOverlayLevel(level: .aboveLabels)
            }
            
            UserAnnotation()
            if let quest = selectedQuest {
                let center = CLLocationCoordinate2D(latitude: quest.target.latitude, longitude: quest.target.longitude)
                if quest.questReached {
                    Marker("", systemImage: "checkmark.circle", coordinate: center).tint(.green)
                } else if quest.type != QuestType.track {
                    if cameraDistance < 2_000.0, quest.questReached == false {
                        MapCircle(center: center, radius: quest.radius)
                            .foregroundStyle(.green.opacity(0.15))
                            .stroke(.green, lineWidth: 2)
                    } else {
                        Marker("", systemImage: quest.type.symbol, coordinate: center).tint(.green)
                    }
                }
                if let pinnedLocation = quest.pinnedLocation {
                    let pinned = CLLocationCoordinate2D(latitude: pinnedLocation.latitude, longitude: pinnedLocation.longitude)
                    Marker("", systemImage: "pin", coordinate: pinned).tint(.green)
                }
                
            }
            if locationManager.isRecording,
               let currentWalk = locationManager.currentWalk{
                MapPolyline(coordinates: currentWalk.coordinates).stroke(.blue, lineWidth: 5)
            }
            
            if showAllWalks, fogModeActive == false {
                let walkPoints: [(points:[GeoPoint],modifier: Double)] = walks.map { walk in
                    var seen = Set<[Double]>()

                    return (points: walk.routeCoordinates.filter { point in
                        seen.insert(getBinnedCoordinates(point)).inserted
                    }
                            , modifier: getDayModifier(walk.createdAt))
                }
                let counts = walkPoints.reduce(into: [[Double]: Double]()) { result, tuple in
                    for point in tuple.points {
                        result[getBinnedCoordinates(point), default: 0] += tuple.modifier
                    }
                }
                let countedPoints = counts.map { entry in
                    (
                        point: GeoPoint(
                            latitude: entry.key[0],
                            longitude: entry.key[1]
                        ),
                        count: entry.value
                    )
                }
                ForEach(0..<countedPoints.count, id: \.self) { index in
                    let item = countedPoints[index]

                    MapCircle(
                        center: CLLocationCoordinate2D(
                            latitude: item.point.latitude,
                            longitude: item.point.longitude
                        ),
                        radius: min(25.0,2.0 + Double(item.count) * 8.0)
                    )
                    .foregroundStyle(
                        Color.blue.opacity(
                            0.4
                        )
                    )
                }
            }
        
            
            if let selectedWalk {
                MapPolyline(coordinates: selectedWalk.coordinates).stroke(.orange, lineWidth: 5)
                if let quest = selectedWalk.quest, selectedWalk.quest?.questReached == true {
                    Marker("", systemImage: "flag.fill", coordinate: CLLocationCoordinate2D(latitude: quest.target.latitude, longitude: quest.target.longitude)).tint(.orange)
                }
            }
        }
        .onMapCameraChange { context in
            cameraDistance = context.camera.distance
        }
        .mapStyle(.standard(
            pointsOfInterest: .excludingAll,
            showsTraffic: false
        ))
    }
}
