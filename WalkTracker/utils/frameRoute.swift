import SwiftUI
import MapKit
import CoreLocation

func frameRoute(for coordinates: [CLLocationCoordinate2D]) -> MapCameraPosition? {
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
