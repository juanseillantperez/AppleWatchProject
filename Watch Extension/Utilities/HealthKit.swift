//
//  HealthKit.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import HealthKit

typealias HealthKitResult = Result<Void,Error>
typealias CompletionHandler =  (HealthKitResult) -> Void

protocol HealthKit {
    func setConfiguration(_ configuration: HKWorkoutConfiguration)
    func setSessionDelegate(delegate: HKWorkoutSessionDelegate?)
    func setBuilderDelegate(delegate: HKLiveWorkoutBuilderDelegate?)
    func initialize(completion: @escaping CompletionHandler)
    func startWorkout(completion: @escaping CompletionHandler)
    func endWorkOut(completion: @escaping CompletionHandler)
    func hasAuthorizationToShare() -> Bool
    func pauseWorkout()
    func resumeWorkout()
    func discardWorkout()
    func workoutHistory(completionHandler: @escaping ([HKWorkout]?, Error?) -> Void)
    func getAVGHeartRate(since:Date, to: Date, completionHandler: @escaping (Double?, Error?) -> Void)
}
