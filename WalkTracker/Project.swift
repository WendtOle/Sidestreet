//
//  Project.swift
//  WalkTracker
//
//  Created by Ole on 05.10.26.
//

import MapKit
import GEOSwift

struct LocalProjection {
    let originLat: Double
    private let mPerDegLat = 111_320.0
    private var mPerDegLon: Double { 111_320.0 * cos(originLat * .pi / 180) }

    func project(_ c: CLLocationCoordinate2D) -> (Double, Double) {
        (c.longitude * mPerDegLon, c.latitude * mPerDegLat)
    }
    func unproject(_ x: Double, _ y: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: y / mPerDegLat, longitude: x / mPerDegLon)
    }
}

func buildStrokeArea(from tracks: [[CLLocationCoordinate2D]],
                     strokeWidthMeters: Double = 15) -> [MKPolygon] {
    guard let originLat = tracks.first?.first?.latitude else { return [] }
    let proj = LocalProjection(originLat: originLat)

    // 1. union all lines (in meters)
    var result: Geometry<XY>?
    for track in tracks {
        guard let line = try? LineString<XY>(coordinates: track.map(proj.project)) else { continue }
        let geometry = Geometry<XY>.lineString(line)
        if let current = result {
            result = (try? current.union(with: geometry)) ?? current
        } else {
            result = geometry
        }
    }

    // 2. give the merged lines a width
    guard let lines = result,
          let area = try? lines.buffer(by: strokeWidthMeters / 2) else { return [] }

    // 3. convert back to map coordinates
    return mkPolygons(from: area, unproject: proj.unproject)
}
