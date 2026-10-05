//
//  Polygon.swift
//  WalkTracker
//
//  Created by Ole on 05.10.26.
//

import MapKit
import GEOSwift

typealias GEOPolygon = Polygon<XY>

// x = longitude, y = latitude
func makePolygon(_ coords: [CLLocationCoordinate2D]) throws -> GEOPolygon {
    var pairs = coords.map { ($0.longitude, $0.latitude) }
    if let first = pairs.first, let last = pairs.last, first != last {
        pairs.append(first) // ring must be closed
    }
    let ring = try GEOPolygon.LinearRing(coordinates: pairs)
    return GEOPolygon(exterior: ring)
}

func ringToCoords(_ ring: GEOPolygon.LinearRing) -> [CLLocationCoordinate2D] {
    ring.coordinates.map { CLLocationCoordinate2D(latitude: $0.y, longitude: $0.x) }
}

func mkPolygon(from polygon: GEOPolygon) -> MKPolygon {
    var exterior = ringToCoords(polygon.exterior)
    let holes = polygon.holes.map { hole -> MKPolygon in
        var c = ringToCoords(hole)
        return MKPolygon(coordinates: &c, count: c.count)
    }
    return MKPolygon(coordinates: &exterior, count: exterior.count, interiorPolygons: holes)
}

func mkPolygons(from geometry: Geometry<XY>) -> [MKPolygon] {
    switch geometry {
    case .polygon(let p):
        return [mkPolygon(from: p)]
    case .multiPolygon(let mp):
        return mp.polygons.map(mkPolygon)
    default:
        return []
    }
}

typealias Unproject = (Double, Double) -> CLLocationCoordinate2D

func ringToCoords(_ ring: GEOPolygon.LinearRing, _ unproject: Unproject) -> [CLLocationCoordinate2D] {
    ring.coordinates.map { unproject($0.x, $0.y) }
}

func mkPolygon(from polygon: GEOPolygon, unproject: Unproject) -> MKPolygon {
    var exterior = ringToCoords(polygon.exterior, unproject)
    let holes = polygon.holes.map { hole -> MKPolygon in
        var c = ringToCoords(hole, unproject)
        return MKPolygon(coordinates: &c, count: c.count)
    }
    return MKPolygon(coordinates: &exterior, count: exterior.count, interiorPolygons: holes)
}

func mkPolygons(from geometry: Geometry<XY>, unproject: @escaping Unproject) -> [MKPolygon] {
    switch geometry {
    case .polygon(let p):
        return [mkPolygon(from: p, unproject: unproject)]
    case .multiPolygon(let mp):
        return mp.polygons.map { mkPolygon(from: $0, unproject: unproject) }
    default:
        return []
    }
}
