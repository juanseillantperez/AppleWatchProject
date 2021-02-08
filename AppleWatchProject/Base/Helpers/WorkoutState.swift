//
//  WorkoutState.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
public struct WorkoutState: Codable {
    public var action: AppleWatchWorkoutAction
    public var source: MessageSource
    public var durationInSeconds: Int?
    public var currentElapsedTime: Double?
    public var startedDate: Date?
    
    public init(action: AppleWatchWorkoutAction,
                source: MessageSource,
                durationInSeconds: Int? = nil,
                currentElapsedTime: Double? = nil,
                startedDate: Date? = nil) {
        self.action = action
        self.source = source
        self.durationInSeconds = durationInSeconds
        self.startedDate = startedDate
    }
    
    public var objc: WorkoutStateObjc {
        WorkoutStateObjc(message: self)
    }
}

public class WorkoutStateObjc : NSObject {
    public var message: WorkoutState
    
    public init(message: WorkoutState) {
        self.message = message
    }
    
    public init(action: AppleWatchWorkoutAction, source: MessageSource, durationInSeconds: Int, startedDate: Date) {
        self.message = WorkoutState(action: action,
                                    source: source,
                                    durationInSeconds: durationInSeconds,
                                    startedDate: startedDate)
    }
}
