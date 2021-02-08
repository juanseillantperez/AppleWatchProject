//
//  Environment.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 05/01/2021.
//

import Foundation

public var Current : Environment = .production

extension Environment {
    public static var production : Environment = {
        return Environment()
    }()
}

public struct Environment {
    public var healthkit : () -> HealthKit = { HealthKitManager() }
    public var appleWatch: () -> AppleWatch = { Environment.appleWatchManagerSI }
    private static let appleWatchManagerSI:AppleWatchManager = AppleWatchManager()

}
