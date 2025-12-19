//
//  VolumeUnit.swift
//  Chugs
//
//  Created by Shay Blum on 18/12/2025.
//

import SwiftUI

enum VolumeUnit: String, CaseIterable {
    case liters
    case ounces
    case gallons
    
    var symbol: String {
        NSLocalizedString(symbolKey, comment: "Volume unit symbol")
    }

    private var symbolKey: String {
        switch self {
        case .liters:
            return "unit.volume.liters"
        case .ounces:
            return "unit.volume.ounces"
        case .gallons:
            return "unit.volume.gallons"
        }
    }

    /// Conversion FROM liters
    func convert(fromLiters liters: Double) -> Double {
        switch self {
        case .liters:
            return liters
        case .ounces:
            return liters * 33.814
        case .gallons:
            return liters * 0.264172
        }
    }
}

extension VolumeUnit {
    static var localeDefault: VolumeUnit {
        let locale = Locale.current

        if locale.measurementSystem == "Metric" {
            return .liters
        } else {
            return .ounces
        }
    }
}

extension Double {
    func formattedVolume(unit: VolumeUnit, fractionDigits: Int = 2) -> String {
        let converted = unit.convert(fromLiters: self)
        return String(
            format: "%.\(fractionDigits)f%@",
            converted,
            unit.symbol
        )
    }
}
