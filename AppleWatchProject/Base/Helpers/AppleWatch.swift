//
//  AppleWatch.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import RxSwift
import RxCocoa
public protocol AppleWatch {
    var caloriesDriver : Driver<Int> {get}
    var heartRateDriver : Driver<Int> {get}
    var workoutState : Driver<WorkoutState> {get}
    var calories: Int {get}
    var heartRate : Int {get}
    var isActive : Bool {get}
    var isWatchAppInstalled : Bool {get}
    var isSupported: Bool {get}
    func initialize()
    func initializeIfNeededBeforeWorkoutStarts()
    func applicationWillTerminate()
    func appDidDiscardWorkout()
    func appDidSaveWorkout()
    func appDidPauseWorkout()
    func appDidResumeWorkout()
    func appDidStartWorkout(withDuration durationInSeconds: Int, startedDate: Date)
    func healthKitPermissionsDidChange()
    func needsToDismissSummaryScreen()
}
