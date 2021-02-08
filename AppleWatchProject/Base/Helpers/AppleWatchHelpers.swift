//
//  AppleWatchHelpers.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
public enum AppMessage: Int, Codable {
    case healthKitPermissionsDidChange
    case needsToDismissSummaryScreen
}
public struct MessageForWatch: Codable {
    public var message: AppMessage
    public init(message: AppMessage) {
        self.message = message
    }
}

public enum AppleWatchWorkoutAction: Int, Codable {
    case discarded
    case paused
    case resumed
    case saved
    case started
}

public enum MessageSource: Int, Codable {
    case phone
    case watch
}

public struct HeartRateSensorData: Codable {
    public init(heartRate: Int) {
        self.heartRate = heartRate
    }
    
    public var heartRate: Int
}

public struct CaloriesSensorData: Codable {
    public init(calories: Int) {
        self.calories = calories
    }
    
    public var calories: Int
}

public struct HKPermissionBeDecidedData: Codable {
    public init(beDecided: Bool) {
        self.beDecided = beDecided
    }
    
    public var beDecided: Bool
}

public struct LaunchMessage: Codable {
    public init(message: MessageToTrack) {
        self.message = message
    }
    
    public var message: MessageToTrack
    
    
}

public enum MessageToTrack: String, Codable {
    case launch
}
