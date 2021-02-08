//
//  PhoneApp.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation

protocol PhoneApp {
    var delegate: PhoneAppDelegate? {get set}
    func initialize()
    func send(calories: Int)
    func send(heartRate: Int)
    func sendUserHasDecidedPermisionsFlag()
    func resumeWorkout()
    func pauseWorkout()
    func finishWorkout()
    func discardWorkout()
    func sendLaunchMessages()
}

protocol PhoneAppDelegate: AnyObject {
    func didPauseWorkout()
    func didResumeWorkout()
    func didStopWorkout()
    func didDiscardWorkout()
    func didStartWorkout(withDuration duration: Int?, startedDate: Date?)
}
