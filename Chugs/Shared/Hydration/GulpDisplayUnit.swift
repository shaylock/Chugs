//
//  GulpDisplayUnit.swift
//  Chugs
//
//  Created by Shay Blum on 18/12/2025.
//

import SwiftUI

enum GulpDisplayUnit {
    case milliliters
    case ounces

    var symbol: String {
        switch self {
        case .milliliters: return NSLocalizedString("unit.volume.milliliters", comment: "")
        case .ounces: return NSLocalizedString("unit.volume.ounces", comment: "")
        }
    }

    func fromLiters(_ liters: Double) -> Int {
        switch self {
        case .milliliters:
            return Int(liters * 1000)
        case .ounces:
            return Int(liters * 33.814)
        }
    }

    func toLiters(_ value: Int) -> Double {
        switch self {
        case .milliliters:
            return Double(value) / 1000
        case .ounces:
            return Double(value) / 33.814
        }
    }
}
