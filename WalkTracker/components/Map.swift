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
    var countedPoints: [(point: GeoPoint, count: Double)]
    @Binding var cameraPosition: MapCameraPosition
    @State private var cameraDistance: Double = 10_000
    var selectedWalk: Walk?
    var selectedQuest: Quest?
    var showAllWalks: Bool
    var quests: [Quest]
    var completedQuests: [Quest]
    
    
    var body: some View {
        Map(position: $cameraPosition){
            UserAnnotation()
            if let quest = selectedQuest, quest.questReached == false {
                let center = CLLocationCoordinate2D(latitude: quest.target.latitude, longitude: quest.target.longitude)
                
                if quest.type != QuestType.track {
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
            
            ForEach(completedQuests) {quest in
                let center = CLLocationCoordinate2D(latitude: quest.target.latitude, longitude: quest.target.longitude)
                Marker("", systemImage: "checkmark.circle", coordinate: center).tint(.orange)
            }
            
            if locationManager.isRecording,
               let currentWalk = locationManager.currentWalk{
                MapPolyline(coordinates: currentWalk.coordinates).stroke(.blue, lineWidth: 5)
            }
            
            if showAllWalks {
                ForEach(0..<countedPoints.count, id: \.self) { index in
                    let item = countedPoints[index]
                    let coordinate = CLLocationCoordinate2D(
                        latitude: item.point.latitude,
                        longitude: item.point.longitude
                    )
                    let maxRadius = 19.0
                    let minRadius = 2.0
                    let scaledUp = Double(item.count) * (maxRadius - minRadius)
                    let radius = min(maxRadius,minRadius + scaledUp)
                    MapCircle(
                        center: coordinate,
                        radius: radius
                    )
                    .foregroundStyle(Color.gray.opacity(0.3))
                    
                    /*
                    Annotation("", coordinate: coordinate, anchor: .center) {
                        Text("\(Int(scaledUp))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.blue)
                            .fixedSize()
                    }
                    */
                    
                }
            }
        
            
            if let selectedWalk {
                MapPolyline(coordinates: selectedWalk.coordinates).stroke(.orange, lineWidth: 5)
                ForEach(selectedWalk.quests) {quest in
                    if quest.questReached == true {
                        Marker("", systemImage: quest.type.symbol, coordinate: CLLocationCoordinate2D(latitude: quest.target.latitude, longitude: quest.target.longitude)).tint(.orange)
                    }
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
