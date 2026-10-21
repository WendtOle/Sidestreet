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
    var recording: Walk?
    var heatMap: [(point: GeoPoint, count: Double)]
    @Binding var cameraPosition: MapCameraPosition
    @State private var closeMode = false
    @State private var cameraDistance: Double = 10_000
    var selectedWalk: Walk?
    var unselectWalk: () -> Void
    var visualizeHeatMap: Bool
    var selectedQuest: QuestData?
    var isLocationServiceEnabled: Bool
    let mapScope: Namespace.ID
    var mapStyle: Style

    var body: some View {
        Map(position: $cameraPosition, scope: mapScope){
            UserAnnotation()
            if let selectedQuest {
                QuestFactory.mapElements(questData: selectedQuest)
            }
            
            if let recording {
                MapPolyline(coordinates: recording.coordinates).stroke(.blue, lineWidth: 5)
            }
            
            if visualizeHeatMap {
                ForEach(0..<heatMap.count, id: \.self) { index in
                    let item = heatMap[index]
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
                ForEach(selectedWalk.quests, id: \.id) { quest in
                    QuestFactory.mapElements(questData: quest)
                }
                if let endPoint = selectedWalk.routeCoordinates.last {
                    Annotation("", coordinate: CLLocationCoordinate2D(
                            latitude: endPoint.latitude,
                            longitude: endPoint.longitude
                        ), anchor: .bottom) {
                            VStack {
                                
                                Button(action: unselectWalk) {
                                    HStack(spacing: 16) {
                                        Text("\(selectedWalk.totalDistance / 1000, specifier: "%.2f") km")
                                            .font(.caption.bold())
                                        Text(formatDuration(selectedWalk.duration))
                                            .font(.caption.bold())
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.secondary)
                                    }
                                }.buttonStyle(.glassProminent)
                                        
                                
                            }.padding(.bottom, 12)
                             
                    }
                    .annotationTitles(.hidden)
                }
            }
        }
        .onMapCameraChange { context in
            let newCloseMode = context.camera.distance < 2_000
            if newCloseMode != closeMode {
                closeMode = newCloseMode
            }
        }
        .mapControls { } // Remove automatically placed controls
        .mapStyle(mapStyle.mapStyle)
    }
}
