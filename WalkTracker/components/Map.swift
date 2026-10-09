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
    var showAllWalks: Bool
    var echoMode: Bool
    
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
            if locationManager.isRecording,
               let currentWalk = locationManager.currentWalk{
                MapPolyline(coordinates: currentWalk.coordinates).stroke(.blue, lineWidth: 5)
                if let quest = currentWalk.quest, echoMode == false {
                    let center = CLLocationCoordinate2D(latitude: quest.target.latitude, longitude: quest.target.longitude)
                    
                    if cameraDistance < 2_000.0, currentWalk.quest?.questReached == false {
                        MapCircle(center: center, radius: quest.radius)
                            .foregroundStyle(.green.opacity(0.15))
                            .stroke(.green, lineWidth: 2)
                    } else {
                        Marker("", systemImage: currentWalk.quest?.questReached == true ? "checkmark.circle" : "flag.fill", coordinate: center)
                            .tint(.green)
                    }
                }
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
