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
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        if isRecording == false {
            return
        }
        if let next = lastLocation {
            if let lastRecordedLocation = nullableLastRecordedLocation {
                currentWalk?.totalDistance += lastRecordedLocation.distance(from: next)
            }
            nullableLastRecordedLocation = next
            currentWalk?.routeCoordinates.append(RoutePoint(latitude: next.coordinate.latitude, longitude: next.coordinate.longitude))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func startRecording() {
        currentWalk = Walk()
        nullableLastRecordedLocation = nil
        isRecording = true
    }
    
    func stopRecording() {
        isRecording = false
    }
}
