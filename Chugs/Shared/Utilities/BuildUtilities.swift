//
//  BuildUtilities.swift
//  Tipot
//
//  Created by Shay Blum on 17/10/2025.
//

import Foundation
import SwiftUI

extension Bundle {
    var appVersionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\(version) (\(build))"
    }
}

final class BuildUtilities {
    @AppStorage("isDebugOverride") private static var isDebugOverride: Bool = false
    static let shared = BuildUtilities()
    
    private init() {}
    
    static let isDebugBuild: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
    
    static var isDebugEnabled: Bool {
        return BuildUtilities.isDebugBuild || isDebugOverride
    }
    
    static func setDebugOverride(_ enabled: Bool) {
        isDebugOverride = enabled
    }
    
    static func resetOverrides() {
        isDebugOverride = false
    }
}
