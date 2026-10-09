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
import GEOSwift
import AVFAudio

struct ContentView: View {
    @StateObject private var soundController = SoundController()
    @State private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition =
        .userLocation(followsHeading: false, fallback: .automatic)
    @State private var cameraDistance: Double = 10_000
    @State private var selectedWalk: Walk?
    @State var isHistoryPresented: Bool = false
    @State private var showAllWalks = true
    @State private var pendingWalk: Walk?
    @State private var showSaveConfirmation = false
    @State private var fogModeActive = false
    @State private var echoMode = false
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Walk.createdAt, order: .reverse)
    private var walks: [Walk]
    
    
    private func onChange (distance: CLLocationDistance) {
        switch distance {
        case 500...:
            soundController.beepInterval = 4 + max(0,(distance - 500) / 50)

        case 200..<500:
            soundController.beepInterval = 2 + max(0, (distance - 200) / 150)

        case 100..<200:
            soundController.beepInterval = 1 + max(0, (distance - 100) / 100)

        case 50..<100:
            soundController.beepInterval = 0.5 + (max(0,(distance - 50) / 100))

        case 0..<50:
            soundController.beepInterval = 0.25 + (max(0,distance / 200))
            
        default:
            break // Ungültige Entfernung
        }
    }
    
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
            withAnimation(
                .timingCurve(
                    0.2, 0.8,
                    0.2, 1.0,
                    duration: 3
                )
            ) {
                cameraPosition = position
            }
        }
    }
    
    private func deleteWalk(_ walk: Walk) {
        modelContext.delete(walk)
        try? modelContext.save()
    }
    
    
    var body: some View {
        ZStack{
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
                    if let quest = selectedWalk.quest, selectedWalk.questReached {
                        Marker("", systemImage: "flag.fill", coordinate: CLLocationCoordinate2D(latitude: quest.questTargetLatitude, longitude: quest.questTargetLongitude)).tint(.orange)
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
            VStack{
                if let walk = selectedWalk {
                    HStack(spacing: 20) {
                        WalkInformation(walk: walk)
                        Button {
                            selectedWalk = nil
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(.plain)
                    }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button {
                            echoMode.toggle()
                        } label: {
                            Image(systemName: echoMode ? "ear" : "eye")
                                .font(.system(size: 18))
                        }
                        .buttonStyle(.glass)
                        
                        Button {
                            if soundController.isRunning {
                                soundController.stop()
                                return
                            }
                            soundController.start()
                        } label: {
                            Image(systemName: soundController.isRunning ? "speaker.wave.3" : "speaker.slash")
                                .font(.system(size: 18))
                        }
                        .buttonStyle(.glass)
                        
                        Button {
                            fogModeActive.toggle()
                        } label: {
                            Image(systemName: fogModeActive ? "moon" : "sun.max")
                                .font(.system(size: 18))
                        }
                        .buttonStyle(.glass)
                        
                        if walks.count > 0 {
                            Button {
                                isHistoryPresented = true
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 18))
                            }
                            .buttonStyle(.glass)
                        }
                        
                    }
                }
                HStack(spacing: 12) {
                    Button {
                        if locationManager.isRecording {
                            locationManager.stopRecording()
                            guard let walk = locationManager.currentWalk else {
                                return
                            }
                            pendingWalk = walk
                            showSaveConfirmation = true
                        } else {
                            locationManager.startRecording()
                            selectedWalk = nil
                        }
                    } label: {
                        if locationManager.isRecording {
                            HStack(spacing: 20) {
                                if let walk = locationManager.currentWalk {
                                    let formattedDistance = walk.totalDistance < 1_000 ? "\(Int(walk.totalDistance)) m" : String(format: "%.2f km", walk.totalDistance / 1_000)
                                    Text(formattedDistance)
                                    Text(formatDuration(walk.duration))
                                }
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .frame(width: 72, height: 50)
                            }
                            .padding(.leading, 12)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 72, height: 50)
                        }
                    }
                    .buttonStyle(.glassProminent)
                    
                    if locationManager.isRecording, locationManager.currentWalk?.quest == nil {
                        Button {
                            Task {
                                await locationManager.addQuest()
                                if echoMode == true {
                                    return
                                }
                                guard let walk = locationManager.currentWalk, let quest = walk.quest, let start = locationManager.lastLocation?.coordinate else {
                                    return
                                }
                                let target: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: quest.questTargetLatitude, longitude: quest.questTargetLongitude)
                                let list: [CLLocationCoordinate2D] = [start, target]
                                if let newFrame = frameRoute(for: list) {
                                    withAnimation(
                                        .timingCurve(
                                            0.2, 0.8,
                                            0.2, 1.0,
                                            duration: 3
                                        )
                                    ) {
                                        cameraPosition = newFrame
                                    }
                                }
                            }
                            
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.glass)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onAppear {
            locationManager.requestPermission()
            locationManager.setOnChange(onChange: onChange)
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
        .confirmationDialog("Save walk?", isPresented: $showSaveConfirmation, titleVisibility: .visible) {
            Button("Save") {
                guard let walk = pendingWalk else { return }
                modelContext.insert(walk)
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
