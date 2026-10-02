//
//  ContentView.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition =
        .userLocation(followsHeading: false, fallback: .automatic)
    //@State private var walks: [Walk] = []
    @State private var selectedWalk: Walk?
    @State var isHistoryPresented: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Walk.createdAt, order: .reverse)
    private var walks: [Walk]
    
    var body: some View {
        ZStack{
            Map(initialPosition: cameraPosition){
                UserAnnotation()
                if let selectedWalk {
                    MapPolyline(coordinates: selectedWalk.coordinates).stroke(.orange, lineWidth: 5)
                } else if let currentWalk = locationManager.currentWalk {
                    MapPolyline(coordinates: currentWalk.coordinates).stroke(.blue, lineWidth: 5)
                }
            }
            VStack{
                Spacer()
                if let location = locationManager.lastLocation {
                    Text("Latitude: \(location.coordinate.latitude)")
                    Text("Longitude: \(location.coordinate.longitude)")
                }
                Text("Distanz: \(Int(locationManager.currentWalk?.totalDistance ?? 0))m")
                if locationManager.isRecording {
                    Text("Runde läuft!")
                    Button("Runde stoppen"){
                        locationManager.stopRecording()
                        if let walk = locationManager.currentWalk {
                            modelContext.insert(walk)
                            do {
                                try modelContext.save()
                            } catch {
                                print(error)
                            }
                        }
                    }
                } else {
                    Text("Keine Runde aktiv")
                    Button("Runde starten"){
                        locationManager.startRecording()
                        selectedWalk = nil
                    }
                }
                if walks.count > 0 {
                    Button("Historie") {
                        isHistoryPresented = true
                    }
                }
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .sheet(isPresented: $isHistoryPresented) {
            WalkHistoryView(walks: walks, selectedWalk: $selectedWalk)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Walk.self, inMemory: true)
}
