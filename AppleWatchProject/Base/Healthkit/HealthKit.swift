//
//  HealthKit.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import HealthKit

public protocol HealthKit {
    var isHealthkitDataAvailable: Bool {get}

    func authorizationStatus(type: HealthKitAttributeObjc) -> HKAuthorizationStatus

    func save(workout:HealthKitWorkoutActivity, onSuccess: Handler<Bool>?, onError: Handler<Error>?)
    
    func workoutHistory(from startDate: Date?, endDate: Date?, limit: NSNumber?, onSuccess: Handler<[HealthkitWorkout]>?, onError: Handler<Error>?)
    
    func startWorkoutOnWatch(type:HKWorkoutActivityType, onSuccess: Action?, onError: Handler<Error>?)
    func requestPermissionToAccessDataInExtension()
    
    func requestAuthorizationTo(write typesToWrite: [HealthKitWriteAttributeObjc],
                                read typesToRead: [HealthKitReadAttributeObjc],
                                completion: @escaping (Bool, Error?) -> Void)
    func getAVGHeartRate(since:Date, toEndDate end: Date, completionHandler: @escaping (Double?, Error?) -> Void)
}
