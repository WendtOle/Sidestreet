import Foundation

func rounded(_ value: Double, step: Double) -> Double {
    return (value / step).rounded() * step
}
