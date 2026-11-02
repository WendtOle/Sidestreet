import MapKit
import SwiftUI
import CoreLocation

func getPath(_ coordinates: [CLLocationCoordinate2D]) -> some MapContent {
    return MapPolyline(coordinates: coordinates).stroke(Color("SecondaryColor").opacity(0.8), lineWidth: 7)
}
