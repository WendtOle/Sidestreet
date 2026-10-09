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
            CustomMap(locationManager: $locationManager, walks: walks, fogModeActive: fogModeActive, cameraPosition: $cameraPosition, selectedWalk: selectedWalk, showAllWalks: showAllWalks, echoMode: echoMode)
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
                SideButtons(echoMode: $echoMode, soundController: soundController, fogModeActive: $fogModeActive, isHistoryPresented: $isHistoryPresented)
                RecordingButton(locationManager: $locationManager, pendingWalk: $pendingWalk, showSaveConfirmation: $showSaveConfirmation, selectedWalk: $selectedWalk)
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
