//
//  Notifications.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation

enum Notifications : String {
    case didFinishWorkout
    case didPauseWorkout
    case didResumeWorkout
    case didDiscardWorkout
    case didFinishWorkoutOnPhone
    case didPauseWorkoutOnPhone
    case didResumeWorkoutOnPhone

    static func postDidUpdateState(_ state: WorkoutState) {
        NotificationCenter.default.post(name: self.didUpdateState, object: state)
    }

    static var didUpdateState: Notification.Name{
         Notification.Name(rawValue: "didUpdateState")
    }

    var name : Notification.Name {
        Notification.Name(rawValue: self.rawValue)
    }

    func post(object: AnyObject? = nil) {
        NotificationCenter.default.post(name: name, object: object)
    }
}
