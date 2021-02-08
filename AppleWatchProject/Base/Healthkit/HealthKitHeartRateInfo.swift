//
//  HealthKitHeartRateInfo.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
public struct HealthKitHeartRateInfo {
    public var startDate: Date
    public var endDate: Date
    public var avgHeartRate: Double
}

public class HealthKitHeartRateInfoObjc: NSObject {
    public init(startDate: Date, endDate: Date, accHeartRate: Double) {
        self.startDate = startDate
        self.endDate = endDate
        self.accHeartRate = accHeartRate
    }

    internal convenience init(info : HealthKitHeartRateInfo) {
        self.init(startDate: info.startDate, endDate:info.endDate, accHeartRate:info.avgHeartRate)
    }

    public var startDate: Date
    public var endDate: Date
    public var accHeartRate: Double
}
