//
//  HealthKitWorkout.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import HealthKit

public protocol HealthkitWorkout {
    var name : String {get}
    var calories : Int {get}
    var sourceApp : String {get}
    var deviceName : String? {get}
    var startInt : TimeInterval {get}
    var stopInt : TimeInterval {get}
    var isOtherAppWorkout: Bool {get}
    var distance: Double {get}
    var identifier: String {get}
}

extension HKWorkout: HealthkitWorkout {
    public var name: String {
        return self.workoutActivityType.activityName
    }
    public var calories: Int {
        Int(self.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)
    }
    public var sourceApp: String {
        return self.sourceRevision.source.name
    }
    public var deviceName: String? {
        return self.device?.name
    }
    public var startInt: TimeInterval {
        return self.startDate.timeIntervalSince1970
    }
    public var stopInt: TimeInterval {
        return self.endDate.timeIntervalSince1970
    }

    public var isOtherAppWorkout: Bool {
        let appDisplayName = Bundle.main.displayName ?? ""
        if self.sourceApp != appDisplayName {
            return true
        }
        return false
    }
    public var distance: Double {
        self.totalDistance?.doubleValue(for: .mile()) ?? 0
    }
    public var identifier: String {
        return self.uuid.uuidString
    }
}

public extension HKWorkoutActivityType {
    
    var activityName: String {
        switch self {
        case .americanFootball:
            return "americanFootball"
        case .archery:
            return "archery"
        case .australianFootball:
            return "australianFootball"
        case .badminton:
            return "badminton"
        case .baseball:
            return "baseball"
        case .basketball:
            return "basketball"
        case .bowling:
            return "bowling"
        case .boxing:
            return "boxing"
        case .climbing:
            return "blimbing"
        case .cricket:
            return "cricket"
        case .crossTraining:
            return "crossTraining"
        case .curling:
            return "curling"
        case .cycling:
            return "cycling"
        case .dance:
            return "dance"
        case .danceInspiredTraining:
            return "danceInspiredTraining"
        case .elliptical:
            return "elliptical"
        case .equestrianSports:
            return "equestrianSports"
        case .fencing:
            return "fencing"
        case .fishing:
            return "fishing"
        case .functionalStrengthTraining:
            return "functionalStrengthTraining"
        case .golf:
            return "golf"
        case .gymnastics:
            return "gymnastics"
        case .handball:
            return "handball"
        case .hiking:
            return "hiking"
        case .hockey:
            return "hockey"
        case .hunting:
            return "hunting"
        case .lacrosse:
            return "lacrosse"
        case .martialArts:
            return "martialArts"
        case .mindAndBody:
            return "mindAndBody"
        case .mixedMetabolicCardioTraining:
            return "mixedMetabolicCardioTraining"
        case .paddleSports:
            return "paddleSports"
        case .play:
            return "play"
        case .preparationAndRecovery:
            return "preparationAndRecovery"
        case .racquetball:
            return "racquetball"
        case .rowing:
            return "rowing"
        case .rugby:
            return "rugby"
        case .running:
            return "running"
        case .sailing:
            return "sailing"
        case .skatingSports:
            return "skatingSports"
        case .snowSports:
            return "snowSports"
        case .soccer:
            return "soccer"
        case .softball:
            return "softball"
        case .squash:
            return "squash"
        case .stairClimbing:
            return "stairClimbing"
        case .surfingSports:
            return "surfingSports"
        case .swimming:
            return "swimming"
        case .tableTennis:
            return "tableTennis"
        case .tennis:
            return "tennis"
        case .trackAndField:
            return "trackAndField"
        case .traditionalStrengthTraining:
            return "traditionalStrengthTraining"
        case .volleyball:
            return "volleyball"
        case .walking:
            return "walking"
        case .waterFitness:
            return "waterFitness"
        case .waterPolo:
            return "waterPolo"
        case .waterSports:
            return "waterSports"
        case .wrestling:
            return "wrestling"
        case .yoga:
            return "yoga"
        case .other:
            return "other"
        case .barre:
            return "barre"
        case .coreTraining:
            return "coreTraining"
        case .crossCountrySkiing:
            return "crossCountrySkiing"
        case .downhillSkiing:
            return "downhillSkiing"
        case .flexibility:
            return "flexibility"
        case .highIntensityIntervalTraining:
            return "highIntensityIntervalTraining"
        case .jumpRope:
            return "jumpRope"
        case .kickboxing:
            return "kickboxing"
        case .pilates:
            return "pilates"
        case .snowboarding:
            return "snowboarding"
        case .stairs:
            return "stairs"
        case .stepTraining:
            return "stepTraining"
        case .wheelchairWalkPace:
            return "wheelchairWalkPace"
        case .wheelchairRunPace:
            return "wheelchairRunPace"
        case .taiChi:
            return "taiChi"
        case .mixedCardio:
            return "mixedCardio"
        case .handCycling:
            return "handCycling"
        case .discSports :
            return "discSports"
        case .fitnessGaming:
            return "fitnessGaming"
        case .cardioDance:
            return "cardioDance"
        case .socialDance:
            return "socialDance"
        case .pickleball:
            return "pickleball"
        case .cooldown :
            return "cooldown"

        @unknown default:
            return ""
        }

    }
    
    static func type(from name: String) -> HKWorkoutActivityType {
        switch name {
        case "americanFootball":
            return .americanFootball
        case "archery":
            return .archery
        case "australianFootball":
            return .australianFootball
        case "badminton":
            return .badminton
        case "baseball":
            return .baseball
        case "basketball":
            return .basketball
        case "bowling":
            return .bowling
        case "boxing":
            return .boxing
        case "climbing":
            return .climbing
        case "cricket":
            return .cricket
        case "crossTraining":
            return .crossTraining
        case "curling":
            return .curling
        case "cycling":
            return .cycling
        case "dance":
            return .dance
        case "danceInspiredTraining":
            return .dance
        case "elliptical":
            return .elliptical
        case "equestrianSports":
            return .equestrianSports
        case "fencing":
            return .fencing
        case "fishing":
            return .fishing
        case "functionalStrengthTraining":
            return .functionalStrengthTraining
        case "golf":
            return .golf
        case "gymnastics":
            return .gymnastics
        case "handball":
            return .handball
        case "hiking":
            return .hiking
        case "hockey":
            return .hockey
        case "hunting":
            return .hunting
        case "lacrosse":
            return .lacrosse
        case "martialArts":
            return .martialArts
        case "mindAndBody":
            return .mindAndBody
        case "mixedMetabolicCardioTraining":
            return .mixedCardio
        case "paddleSports":
            return .paddleSports
        case "play":
            return .play
        case "preparationAndRecovery":
            return .preparationAndRecovery
        case "racquetball":
            return .racquetball
        case "rowing":
            return .rowing
        case "rugby":
            return .rugby
        case "running":
            return .running
        case "sailing":
            return .sailing
        case "skatingSports":
            return .skatingSports
        case "snowSports":
            return .snowSports
        case "soccer":
            return .soccer
        case "softball":
            return .softball
        case "squash":
            return .squash
        case "stairClimbing":
            return .stairClimbing
        case "surfingSports":
            return .surfingSports
        case "swimming":
            return .swimming
        case "tableTennis":
            return .tableTennis
        case "tennis":
            return .tennis
        case "trackAndField":
            return .trackAndField
        case "traditionalStrengthTraining":
            return .traditionalStrengthTraining
        case "volleyball":
            return .volleyball
        case "walking":
            return .walking
        case "waterFitness":
            return .waterFitness
        case "waterPolo":
            return .waterPolo
        case "waterSports":
            return .waterSports
        case "wrestling":
            return .wrestling
        case "yoga":
            return .yoga
        case "other":
            return .other
        case "barre":
            return .barre
        case "coreTraining":
            return .coreTraining
        case "crossCountrySkiing":
            return .crossCountrySkiing
        case "downhillSkiing":
            return .downhillSkiing
        case "flexibility":
            return .flexibility
        case "highIntensityIntervalTraining":
            return .highIntensityIntervalTraining
        case "jumpRope":
            return .jumpRope
        case "kickboxing":
            return .kickboxing
        case "pilates":
            return .pilates
        case "snowboarding":
            return .snowboarding
        case "stairs":
            return .stairs
        case "stepTraining":
            return .stepTraining
        case "wheelchairWalkPace":
            return .wheelchairWalkPace
        case "wheelchairRunPace":
            return .wheelchairRunPace
        case "taiChi":
            return .taiChi
        case "mixedCardio":
            return .mixedCardio
        case "handCycling":
            return .handCycling
        case "discSports":
            if #available(iOS 13.0, *) {
                return .discSports
            } else {
                return .other
            }
        case "fitnessGaming":
            if #available(iOS 13.0, *) {
                return .fitnessGaming
            } else {
                return .other
            }
        default:
            return .other
        }
    }
}
