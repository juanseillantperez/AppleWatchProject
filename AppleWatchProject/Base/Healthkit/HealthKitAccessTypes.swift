//
//  HealthKitAccessTypes.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import HealthKit
public enum HealthKitWriteAttribute: Int {
    case height
    case bodyMass
    case workout
    case activeEnergy
    case heartRate
}

public class HealthKitWriteAttributeObjc : NSObject, HealthKitAttributeObjc {
    
    public let attribute:HealthKitWriteAttribute
    
    internal init(attribute: HealthKitWriteAttribute) {
        self.attribute = attribute
    }

    public var objectType: HKObjectType? {
        attribute.objectType
    }

    public var sampleType: HKSampleType {
        attribute.sampleType
    }
}

public extension HealthKitWriteAttribute {
    var objc:HealthKitWriteAttributeObjc {
        HealthKitWriteAttributeObjc(attribute: self)
    }
}

extension HealthKitWriteAttribute : HealthKitAttribute {
    public var objectType: HKObjectType? {
        switch self {
        case .height:
            return HKObjectType.quantityType(forIdentifier: .height)
        case .bodyMass:
            return HKObjectType.quantityType(forIdentifier: .bodyMass)
        case .workout:
            return HKObjectType.workoutType()
        case .activeEnergy:
            return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        case .heartRate:
            return HKObjectType.quantityType(forIdentifier: .heartRate)
        }
    }

    public var sampleType: HKSampleType {
        return (self.objectType as? HKSampleType)!
    }
}

public enum HealthKitReadAttribute : Int {
    case sex
    case age
    case dateOfBirth
    case height
    case bodyMass
    case workout
    case activeEnergy
    case heartRate
}


public class HealthKitReadAttributeObjc : NSObject, HealthKitAttributeObjc {
    public let attribute: HealthKitReadAttribute
    
    internal init(attribute: HealthKitReadAttribute) {
        self.attribute = attribute
    }

    public var objectType: HKObjectType? {
        attribute.objectType
    }

    public var sampleType: HKSampleType {
        attribute.sampleType
    }
}

public extension HealthKitReadAttribute {
    var objc:HealthKitReadAttributeObjc {
        HealthKitReadAttributeObjc(attribute: self)
    }
}

extension HealthKitReadAttribute : HealthKitAttribute {
    public var objectType: HKObjectType? {
        switch self {
        case .dateOfBirth, .age:
            return HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
        case .sex:
            return HKObjectType.characteristicType(forIdentifier: .biologicalSex)
        case .height:
            return HKObjectType.quantityType(forIdentifier: .height)
        case .bodyMass:
            return HKObjectType.quantityType(forIdentifier: .bodyMass)
        case .workout:
            return HKObjectType.workoutType()
        case .activeEnergy:
            return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        case .heartRate:
            return HKObjectType.quantityType(forIdentifier: .heartRate)
        }
    }
    public var sampleType: HKSampleType {
        return (self.objectType as? HKSampleType)!
    }
}

public protocol HealthKitAttribute {
    var objectType : HKObjectType? {get}
    var sampleType : HKSampleType {get}
}

public protocol HealthKitAttributeObjc {
    var objectType : HKObjectType? {get}
    var sampleType : HKSampleType {get}
}
