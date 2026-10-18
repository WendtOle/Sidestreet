//
//  SessionActivityExtensionAttributes.swift
//  WalkTracker
//
//  Created by Ole on 17.10.26.
//
import ActivityKit

struct SessionActivityExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {}

    var name: String
}
