//
//  round.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//
import Foundation

func rounded(_ value: Double, step: Double) -> Double {
    return (value / step).rounded() * step
}
