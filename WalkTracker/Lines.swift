import MapKit
import GEOSwift

// x = longitude, y = latitude; a line needs at least 2 points
func makeLine(_ coords: [CLLocationCoordinate2D]) throws -> LineString<XY> {
    try LineString<XY>(coordinates: coords.map { ($0.longitude, $0.latitude) })
}

func mkPolyline(from line: LineString<XY>) -> MKPolyline {
    let coords = line.coordinates.map {
        CLLocationCoordinate2D(latitude: $0.y, longitude: $0.x)
    }
    return MKPolyline(coordinates: coords, count: coords.count)
}

func mkPolylines(from geometry: Geometry<XY>) -> [MKPolyline] {
    switch geometry {
    case .lineString(let line):
        return [mkPolyline(from: line)]
    case .multiLineString(let multi):
        return multi.lineStrings.map(mkPolyline)
    default:
        return []
    }
}

func buildLineUnion(from tracks: [[CLLocationCoordinate2D]]) -> [MKPolyline] {
    var result: Geometry<XY>?

    for track in tracks {
        guard let line = try? makeLine(track) else { continue } // skips tracks with < 2 points
        let geometry = Geometry<XY>.lineString(line)

        if let current = result {
            result = (try? current.union(with: geometry)) ?? current
        } else {
            result = geometry
        }
    }

    guard let result else { return [] }
    return mkPolylines(from: result)
}
