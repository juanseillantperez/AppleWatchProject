//
//  Toolbox.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation

public struct Toolbox {

    var phoneApp : () -> PhoneApp = { Toolbox.phoneManagerSI }
    var healthKit : () -> HealthKit = { Toolbox.healthKitSI }

    private static let phoneManagerSI : PhoneManager = PhoneManager()
    private static let healthKitSI : HealthKitManager = HealthKitManager()
}
