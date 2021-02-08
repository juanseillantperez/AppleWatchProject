//
//  HealthKitWorkoutActivity.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import HealthKit

public class HealthKitWorkoutActivity : NSObject {

    public var startDate: Date
    public var endDate: Date
    public var activityType: HKWorkoutActivityType
    public var energyBurned: Double
    public var duration: Int?
    public var totalDistanceInMiles: Double?
    public var heartRateObjc : HealthKitHeartRateInfoObjc?

    internal init(startDate: Date, endDate: Date, activityType: HKWorkoutActivityType, energyBurned: Double, duration: Int? = nil, totalDistanceInMiles: Double? = nil, heartRateObjc: HealthKitHeartRateInfoObjc?) {
        self.startDate = startDate
        self.endDate = endDate
        self.activityType = activityType
        self.energyBurned = energyBurned
        self.duration = duration
        self.heartRateObjc = heartRateObjc
        self.totalDistanceInMiles = totalDistanceInMiles
    }

    var heartRate : HealthKitHeartRateInfo? {
        heartRateObjc.map{
            HealthKitHeartRateInfo(startDate:$0.startDate,
                                   endDate:$0.endDate,
                                   avgHeartRate:$0.accHeartRate)
        }

    }

    var workoutDuration: TimeInterval {
        if let durationWorkout = duration {
            return TimeInterval(durationWorkout)
        } else {
            return endDate.timeIntervalSince(startDate)
        }
    }

    var calculateEnergyBurned: Double {

        let prancerciseCaloriesPerHour: Double = 450
        var hours: Double

        if let totalDuration = duration {
            hours = Double(totalDuration) / 3600
        } else {
            hours = workoutDuration / 3600
        }

        let totalCalories = prancerciseCaloriesPerHour*hours
        return totalCalories
    }

    var calorieQuantity : HKQuantity {
        let energyBurnedInWorkout = self.energyBurned > 0 ? self.energyBurned : self.calculateEnergyBurned

        return HKQuantity(unit: UnitHealthKit.kilocalorie,
                          doubleValue: energyBurnedInWorkout)
    }
    
    var distanceQuantity : HKQuantity? {
        guard let totalDistanceInMiles = self.totalDistanceInMiles else {return nil}
        return HKQuantity(unit: .mile(),
                          doubleValue: totalDistanceInMiles)
    }
}

public enum WorkoutActivityTypeHealthKit: Int {
    case other
    case cardio
    case yoga
    case strength
    case running
    case cycling
    case dance
    case gymnastics

    public var type : HKWorkoutActivityType {
        switch self {
        case .other:
            return HKWorkoutActivityType.other
        case .cardio:
            return HKWorkoutActivityType.mixedCardio
        case .yoga:
            return HKWorkoutActivityType.yoga
        case .strength:
            return HKWorkoutActivityType.traditionalStrengthTraining
        case .running:
            return HKWorkoutActivityType.running
        case .cycling:
            return HKWorkoutActivityType.cycling
        case .dance:
            return HKWorkoutActivityType.dance
        case .gymnastics:
            return HKWorkoutActivityType.gymnastics
        }
    }

}
