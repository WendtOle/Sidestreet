//
//  LocationManager.swift
//  WalkTracker
//
//  Created by Ole on 02.10.26.
//

import CoreLocation
import Observation

@Observable
@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var lastLocation: CLLocation?
    var nullableLastRecordedLocation: CLLocation?
    var isRecording = false
    var currentWalk: Walk?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    var distanceToQuest: CLLocationDistance?
    private var onQuestDistanceChange: ((CLLocationDistance) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        
        manager.activityType = .fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
    }
    
    func setOnChange (onChange: @escaping(CLLocationDistance) -> Void) {
        self.onQuestDistanceChange = onChange
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestCurrentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
                locationContinuation = continuation

                manager.requestLocation()
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let next = locations.last else {
            return
        }
        lastLocation = next
        
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: next)
        }

        guard isRecording else {
            return
        }
        
        guard next.horizontalAccuracy >= 0, next.horizontalAccuracy <= 20 else {
            return
        }
        
        if let lastRecordedLocation = nullableLastRecordedLocation {
            let distance = lastRecordedLocation.distance(from: next)
            let time = next.timestamp.timeIntervalSince(lastRecordedLocation.timestamp)
            guard time > 0 else {
                return
            }
            let speed = distance / time
            guard speed <= 4.0 else {
                print("Ignoring GPS jump:", distance, "m in", time, "s")
                return
            }
            currentWalk?.totalDistance += distance
            currentWalk?.duration += time
        }
        if let quest = currentWalk?.quest, currentWalk?.questReached == false {
            distanceToQuest = next.distance(from: CLLocation(latitude: quest.questTargetLatitude, longitude: quest.questTargetLongitude))
            if let distance = distanceToQuest, let onChange = onQuestDistanceChange {
                onChange(distance)
            }
            if isQuestReached(quest: quest, location: next) {
                currentWalk?.questReached = true
                distanceToQuest = nil
            }
        }
        nullableLastRecordedLocation = next
        currentWalk?.routeCoordinates.append(RoutePoint(latitude: next.coordinate.latitude, longitude: next.coordinate.longitude))
        
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(throwing: error)
        }
        
        print("Location error:", error)
    }
    
    func startRecording() {
        currentWalk = Walk()
        nullableLastRecordedLocation = nil
        isRecording = true
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }
    
    func addQuest() async {
        guard isRecording else {
            return
        }
        var quest: Quest?
        do {
            let location = try await requestCurrentLocation()
            quest = getQuest(startingPoint: location)
            currentWalk?.quest = quest
        } catch {
            print("Location konnte nicht ermittelt werden:", error)
        }
    }
    
    func stopRecording() {
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
        isRecording = false
        distanceToQuest = nil
    }
}
