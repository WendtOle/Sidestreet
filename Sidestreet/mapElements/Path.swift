import MapKit
import SwiftUI
import CoreLocation

func getPath(_ coordinates: [CLLocationCoordinate2D]) -> some MapContent {
    return MapPolyline(coordinates: coordinates).stroke(.blue, lineWidth: 7)
}
