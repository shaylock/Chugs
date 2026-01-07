//
//  LoggerUtilities.swift
//  Tipot
//
//  Created by Shay Blum on 17/10/2025.
//

import os
import Foundation

struct LoggerUtilities {
    static func makeLogger(for type: Any.Type) -> Logger {
        let subsystem = Bundle.main.bundleIdentifier ?? "com.yourapp.unknown"
        let category = String(describing: type)
        return Logger(subsystem: subsystem, category: category)
    }
}
