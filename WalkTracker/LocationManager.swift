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
    
    override init() {
        super.init()
        manager.delegate = self
        
        manager.activityType = .fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let next = locations.last else {
            return
        }
        lastLocation = next

        guard isRecording else {
            return
        }
        
        guard next.horizontalAccuracy >= 0, next.horizontalAccuracy <= 30 else {
            return
        }
        
        if let lastRecordedLocation = nullableLastRecordedLocation {
            currentWalk?.totalDistance += lastRecordedLocation.distance(from: next)
        }
        nullableLastRecordedLocation = next
        currentWalk?.routeCoordinates.append(RoutePoint(latitude: next.coordinate.latitude, longitude: next.coordinate.longitude))
        
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error:", error)
    }
    
    func startRecording() {
        currentWalk = Walk()
        nullableLastRecordedLocation = nil
        isRecording = true
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }
    
    func stopRecording() {
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
        isRecording = false
    }
}
