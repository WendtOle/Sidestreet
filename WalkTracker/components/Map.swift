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
                
            }
            if locationManager.isRecording,
               let currentWalk = locationManager.currentWalk{
                MapPolyline(coordinates: currentWalk.coordinates).stroke(.blue, lineWidth: 5)
            }
            
            if showAllWalks, fogModeActive == false {
                ForEach(walks) {walk in
                    MapPolyline(coordinates: walk.coordinates)
                        .stroke(
                            .gray.opacity(0.5),
                            style: StrokeStyle(
                                lineWidth: 16,
                                lineCap: .round,
                                lineJoin: .round
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
