//
//  FogPolygon.swift
//  WalkTracker
//
//  Created by Ole on 05.10.26.
//

import MapKit

enum FogPolygonBuilder {

    /// Creates one large polygon covering the whole world,
    /// with holes where the user has already walked.
    static func makeFogPolygon(
        walks: [Walk],
        revealRadius: CLLocationDistance = 50
    ) -> MKPolygon {

        let exploredPolygons = walks.compactMap {
            makeRouteCorridor(
                coordinates: $0.coordinates,
                radius: revealRadius
            )
        }

        let worldPoints = [
            MKMapRect.world.origin,
            MKMapPoint(
                x: MKMapRect.world.minX,
                y: MKMapRect.world.maxY
            ),
            MKMapPoint(
                x: MKMapRect.world.maxX,
                y: MKMapRect.world.maxY
            ),
            MKMapPoint(
                x: MKMapRect.world.maxX,
                y: MKMapRect.world.minY
            )
        ]

        return MKPolygon(
            points: worldPoints,
            count: worldPoints.count,
            interiorPolygons: exploredPolygons
        )
    }


    /// Turns one GPS route into a thick polygon corridor.
    private static func makeRouteCorridor(
        coordinates: [CLLocationCoordinate2D],
        radius: CLLocationDistance
    ) -> MKPolygon? {

        guard !coordinates.isEmpty else {
            return nil
        }

        // A single GPS point:
        // create a circular revealed area.
        if coordinates.count == 1 {
            return makeCirclePolygon(
                center: coordinates[0],
                radius: radius
            )
        }

        let mapPoints = coordinates.map {
            MKMapPoint($0)
        }

        var leftPoints: [MKMapPoint] = []
        var rightPoints: [MKMapPoint] = []

        for index in mapPoints.indices {

            let current = mapPoints[index]

            let direction: MKMapPoint

            if index == 0 {
                direction = MKMapPoint(
                    x: mapPoints[1].x - current.x,
                    y: mapPoints[1].y - current.y
                )
            } else if index == mapPoints.count - 1 {
                direction = MKMapPoint(
                    x: current.x - mapPoints[index - 1].x,
                    y: current.y - mapPoints[index - 1].y
                )
            } else {
                direction = MKMapPoint(
                    x: mapPoints[index + 1].x - mapPoints[index - 1].x,
                    y: mapPoints[index + 1].y - mapPoints[index - 1].y
                )
            }

            let length = sqrt(
                direction.x * direction.x +
                direction.y * direction.y
            )

            guard length > 0 else {
                continue
            }

            let normalX = -direction.y / length
            let normalY = direction.x / length

            let latitude = coordinates[index].latitude

            let mapPointsPerMeter =
                MKMapPointsPerMeterAtLatitude(latitude)

            let offset = radius * mapPointsPerMeter

            leftPoints.append(
                MKMapPoint(
                    x: current.x + normalX * offset,
                    y: current.y + normalY * offset
                )
            )

            rightPoints.append(
                MKMapPoint(
                    x: current.x - normalX * offset,
                    y: current.y - normalY * offset
                )
            )
        }

        guard !leftPoints.isEmpty else {
            return nil
        }

        // Left side forward + right side backwards
        // creates one closed corridor polygon.
        let polygonPoints =
            leftPoints +
            rightPoints.reversed()

        return MKPolygon(
            points: polygonPoints,
            count: polygonPoints.count
        )
    }


    /// Creates a polygon approximation of a circle.
    private static func makeCirclePolygon(
        center: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        segments: Int = 24
    ) -> MKPolygon {

        let centerPoint = MKMapPoint(center)

        let mapPointsPerMeter =
            MKMapPointsPerMeterAtLatitude(center.latitude)

        let mapRadius = radius * mapPointsPerMeter

        var points: [MKMapPoint] = []

        for index in 0..<segments {

            let angle =
                (Double(index) / Double(segments))
                * 2
                * .pi

            points.append(
                MKMapPoint(
                    x: centerPoint.x + cos(angle) * mapRadius,
                    y: centerPoint.y + sin(angle) * mapRadius
                )
            )
        }

        return MKPolygon(
            points: points,
            count: points.count
        )
    }
}
