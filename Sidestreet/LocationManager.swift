import CoreLocation
import Observation
import Combine

enum LocationAccessStatus {
    case enabled
    case reducedAccuracy
    case globallyOff
    case appPermissionDenied
}

@Observable
@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private(set) var locationAccessStatus: LocationAccessStatus = .enabled
    private(set) var preciseLocationAllowed = false
    private let manager = CLLocationManager()
    var lastLocation: CLLocation?
    var nullableLastRecordedLocation: CLLocation?
    var isRecording = false
    private var onLocationUpdate: (_ location: CLLocation, _ distanceToPrev: CLLocationDistance?, _ timeSincePrev: Double?) -> Void
    
    init(onLocationUpdate: @escaping (CLLocation, CLLocationDistance?, Double?) -> Void) {
        self.onLocationUpdate = onLocationUpdate
        super.init()
        manager.delegate = self
        
        manager.activityType = .fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
    }
    
    func requestPermission() {
        guard manager.authorizationStatus == .notDetermined else { return }
        manager.requestWhenInUseAuthorization()
    }
    
    func updateServiceEnabledStatus() async {
        let enabled = await Task.detached(priority: .utility) {
            CLLocationManager.locationServicesEnabled()
        }.value

        guard !Task.isCancelled else {
            return
        }
        
        if !enabled {
            locationAccessStatus = .globallyOff
            return
        }
        
        let status = manager.authorizationStatus
        if status == .notDetermined {
            requestPermission()
            locationAccessStatus = .appPermissionDenied
            return
        }
        if status != .authorizedWhenInUse && status != .authorizedAlways {
            locationAccessStatus = .appPermissionDenied
            return
        }
        if manager.accuracyAuthorization != .fullAccuracy {
            locationAccessStatus = .reducedAccuracy
            return
        }
        locationAccessStatus = .enabled
    }
    
    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        Task { @MainActor [weak self] in
            await self?.updateServiceEnabledStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let next = locations.last else {
            return
        }
        lastLocation = next

        guard isRecording else {
            return
        }
        
        guard next.horizontalAccuracy >= 0, next.horizontalAccuracy <= 20 else {
            return
        }

        guard let lastRecordedLocation = nullableLastRecordedLocation else {
            onLocationUpdate(next, nil, nil)
            nullableLastRecordedLocation = next
            return
        }
        
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
        
        onLocationUpdate(next, distance, time)
        nullableLastRecordedLocation = next
    }
    
    func startRecording() {
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
