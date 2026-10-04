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
    @State private var cameraDistance: Double = 10_000
    @State private var selectedWalk: Walk?
    @State var isHistoryPresented: Bool = false
    @State private var showAllWalks = true
    @State private var pendingWalk: Walk?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Walk.createdAt, order: .reverse)
    private var walks: [Walk]
    
    private func debugDumpWalks() {
        do {
            let descriptor = FetchDescriptor<Walk>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )

            let storedWalks = try modelContext.fetch(descriptor)

            print("===== STORED WALKS =====")
            print("Count:", storedWalks.count)

            for walk in storedWalks {
                print("Walk:", walk.id)
                print("Created:", walk.createdAt)
                print("Distance:", walk.totalDistance)
                print("Route points:", walk.routeCoordinates.count)
                print("Quest:", walk.quest)
                print("------------------------")
            }
        } catch {
            print("FETCH ERROR:", error)
        }
    }
    
    private func frameRoute(for coordinates: [CLLocationCoordinate2D]) -> MapCameraPosition? {
        guard let first = coordinates.first else {
            return nil
        }
        
        guard coordinates.count > 1 else {
            return nil
        }
        
        var rect = MKMapRect(
            origin: MKMapPoint(first),
            size: MKMapSize(width: 0, height: 0)
        )
        for coordinate in coordinates.dropFirst(){
            let point = MKMapPoint(coordinate)
            
            let pointRect = MKMapRect(
                origin: point,
                size: MKMapSize(width: 0, height: 0)
            )
            rect = rect.union(pointRect)
        }
        let padding = 0.15
        let paddedRect = rect.insetBy(dx: -rect.size.width * padding, dy: -rect.size.height * padding)
        return .rect(paddedRect)
    }
    
    private func selectedWalk(_ walk: Walk) {
        selectedWalk = walk
            if let position = frameRoute(for: walk.coordinates) {
                cameraPosition = position
            }
    }
    
    private func deleteWalk(_ walk: Walk) {
        modelContext.delete(walk)
        try? modelContext.save()
    }
    
    var body: some View {
        ZStack{
            Map(position: $cameraPosition){
                UserAnnotation()
                if locationManager.isRecording,
                   let currentWalk = locationManager.currentWalk{
                    MapPolyline(coordinates: currentWalk.coordinates).stroke(.blue, lineWidth: 5)
                    if let quest = currentWalk.quest {
                        let center = CLLocationCoordinate2D(latitude: quest.questTargetLatitude, longitude: quest.questTargetLongitude)
                       
                        if cameraDistance < 2_000.0, currentWalk.questReached == false {
                            MapCircle(center: center, radius: quest.questTargetRadius)
                                .foregroundStyle(.green.opacity(0.15))
                                .stroke(.green, lineWidth: 2)
                        } else {
                            Marker("", systemImage: currentWalk.questReached ? "checkmark.circle" : "flag.fill", coordinate: center)
                                .tint(.green)
                        }
                    }
                }
                
                if showAllWalks {
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
                }
            }
            .onMapCameraChange { context in
                cameraDistance = context.camera.distance
            }
            VStack{
                HStack {
                    Spacer()
                    if walks.count > 0 {
                        Button {
                            isHistoryPresented = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title3)
                        }
                        .buttonStyle(.glass)
                    }
                }
                Spacer()
                VStack(spacing: 12) {
                    Button {
                        if locationManager.isRecording {
                            locationManager.stopRecording()
                            guard let walk = locationManager.currentWalk else {
                                return
                            }
                            pendingWalk = walk
                        } else {
                            Task {
                                await locationManager.startRecording()
                                if let walk = locationManager.currentWalk, let quest = walk.quest, let start = locationManager.lastLocation?.coordinate {
                                    let target: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: quest.questTargetLatitude, longitude: quest.questTargetLongitude)
                                    let list: [CLLocationCoordinate2D] = [start, target]
                                    cameraPosition = frameRoute(for: list) ?? cameraPosition
                                }
                            }
                            selectedWalk = nil
                        }
                    } label: {
                        Image(systemName: locationManager.isRecording ? "stop.fill" : "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .frame(width: 72, height: 72)
                        
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .sheet(isPresented: $isHistoryPresented) {
            WalkHistoryView(walks: walks, onSelect: selectedWalk, onDelete: deleteWalk)
                .presentationDetents([.medium, .large])
        }
        .onChange(of: selectedWalk?.id) {
            guard let selectedWalk else {
                return
            }
            cameraPosition = frameRoute(for: selectedWalk.coordinates) ?? cameraPosition
        }
        .confirmationDialog("Save walk?", item: $pendingWalk, titleVisibility: .visible) { walk in
            Button("Save") {
                modelContext.insert(walk)
                try? modelContext.save()
                pendingWalk = nil
            }
            Button("Discard", role: .destructive) {
                pendingWalk = nil
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Walk.self, inMemory: true)
}
