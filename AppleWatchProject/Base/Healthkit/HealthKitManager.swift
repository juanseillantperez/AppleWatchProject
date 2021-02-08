//
//  HealthKitManager.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import HealthKit

public class HealthKitManager: NSObject, HealthKit {

    let healthKitStore = HKHealthStore()

    //MARK: - public
    @objc
    public override init() {
        super.init()
    }
    
    public var isHealthkitDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    public func requestPermissionToAccessDataInExtension() {
        self.healthKitStore.handleAuthorizationForExtension { (_, _) in  }
    }

    func authorizationStatus(type: HealthKitAttribute) -> HKAuthorizationStatus {
        return self.healthKitStore.authorizationStatus(for: type.objectType!)
    }

    public func authorizationStatus(type: HealthKitAttributeObjc) -> HKAuthorizationStatus {
        return self.healthKitStore.authorizationStatus(for: type.objectType!)
    }

    public func requestAuthorizationTo(write typesToWrite: [HealthKitWriteAttributeObjc],
                                       read typesToRead: [HealthKitReadAttributeObjc],
                                       completion: @escaping (Bool, Error?) -> Void) {
        let writeTypes : Set<HKSampleType> = Set(typesToWrite.map { object in
            return object.attribute.sampleType
        })
        
        let readTypes = Set(typesToRead.map { object in
            return object.attribute.objectType!
        })
        
        print("❤️ will ask \(healthKitStore)")
        self.healthKitStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
            print("❤️ self.healthKitStore.requestAuthorization; success:\(success) error: \(error.debugDescription)")
            if let error = error {
                completion(success, HealthKitError.error(error))
            } else {
                completion(success, nil)
            }
        }
    }

    public func getAVGHeartRate(since:Date, toEndDate end: Date, completionHandler: @escaping (Double?, Error?) -> Void) {
        let typeHeart = HKQuantityType.quantityType(forIdentifier: .heartRate)
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: since, end: end, options: HKQueryOptions.strictEndDate)
        let query = HKStatisticsQuery(quantityType: typeHeart!, quantitySamplePredicate: predicate, options: .discreteAverage) { (_, result, error) in
            if let result = result {
                let quantity: HKQuantity? = result.averageQuantity()
                let beats: Double? = quantity?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                completionHandler(beats, nil)
            } else {
                completionHandler(nil, error)
            }
        }
        self.healthKitStore.execute(query)
    }

    var userAge: NSNumber? {
        guard let birthdayComponent = try? self.healthKitStore.dateOfBirthComponents() else {return nil}
        let today = Date()
        let calendar =  Calendar.current
        let todayDateComponents = calendar.dateComponents([.year], from: today)

        guard let thisYear = todayDateComponents.year, let birthdayYear = birthdayComponent.year else {
            return nil
        }
        return NSNumber(value: thisYear - birthdayYear)
    }

    public func userDateOfBirth() throws -> DateComponents {
        return try self.healthKitStore.dateOfBirthComponents()
    }

    func userSex() throws -> HKBiologicalSex {
        return try healthKitStore.biologicalSex().biologicalSex
    }

    public func userHeight(completion: @escaping (HKQuantity?, Error?) -> Void) {
        self.getDataFromHealthKitStore(typeIdentifier: HKQuantityTypeIdentifier.height, completionHandler: completion)
    }

    public func userBodyMass(completion: @escaping (HKQuantity?, Error?) -> Void) {
        self.getDataFromHealthKitStore(typeIdentifier: HKQuantityTypeIdentifier.bodyMass, completionHandler: completion)
    }

    func userHeartRatesQuantities(completion: @escaping ([HKQuantity], Error?) -> Void) {

        self.getDataFromHealthKitStore(typeIdentifier: HKQuantityTypeIdentifier.heartRate, withlimit: HKObjectQueryNoLimit) { (results, error) in
            guard let results = results else {
                return completion([], error)
            }
            let result : [HKQuantity] = results.compactMap {sample in
                return (sample as? HKQuantitySample)?.quantity
            }
            completion(result, nil)
        }
    }

    public func lastUserHeartRate(onSuccess: Handler<Double>?, onError: Handler<Error>?) {
        self.getDataFromHealthKitStore(typeIdentifier: HKQuantityTypeIdentifier.heartRate) { (result, error) in
            if let error = error {
                onError?(error)
                return
            }
            guard let quantity = result else {
                onError?(HealthKitError.quantityTypeIdentifierUnknown)
                return
            }
            onSuccess?(quantity.doubleValue(for: UnitHealthKit.heartRate))
        }
    }

    public func userHeartRates(completion: @escaping ([Double], Error?) -> Void) {
        self.userHeartRatesQuantities { (quantitiesFromHK, error) in
            if let e = error {
                return completion([], e)
            }
            let values = quantitiesFromHK.map { $0.doubleValue(for: UnitHealthKit.heartRate)}
            completion(values, nil)
        }
    }

    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        return self.healthKitStore.authorizationStatus(for: type)
    }

    func getDataFromHealthKitStore(typeIdentifier: HKQuantityTypeIdentifier, completionHandler: @escaping (HKQuantity?, Error?) -> Void) {

        self.getDataFromHealthKitStore(typeIdentifier: typeIdentifier, withlimit: 1) { (results, error) in
            if let samples = results,
                let sample = samples.first,
                let result = sample as? HKQuantitySample {
                completionHandler(result.quantity, error)
            } else {
                completionHandler(nil, error)
            }
        }
    }

    func getDataFromHealthKitStore(typeIdentifier: HKQuantityTypeIdentifier, withlimit limit: Int, completionHandler: @escaping ([HKSample]?, Error?) -> Void) {

        guard let type = HKSampleType.quantityType(forIdentifier: typeIdentifier) else {
            return completionHandler(nil, HealthKitError.quantityTypeIdentifierUnknown)
        }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: limit, sortDescriptors:[sortDescriptor]) { (_, results, error) in
            completionHandler(results, error)
        }
        self.healthKitStore.execute(query)
    }

    public func save(workout: HealthKitWorkoutActivity, onSuccess: Handler<Bool>?, onError: Handler<Error>?) {

        let calorieQuantity = workout.calorieQuantity
        let totalDistanceQuantity = workout.distanceQuantity
        let workoutDuration = workout.workoutDuration

        self.saveWorkout(saveInfo: (activityType: workout.activityType,
                                    start: workout.startDate,
                                    end: workout.endDate,
                                    duration: workoutDuration,
                                    totalEnergyBurned: calorieQuantity,
                                    totalDistance: totalDistanceQuantity,
                                    device: HKDevice.local(),
                                    metadata: nil,
                                    heartRate: workout.heartRate),
                         completionHandler: {(success, error) in
                            if let error = error {
                                onError?(error)
                            } else {
                                onSuccess?(success)
                            }
        })

    }

    public func workoutHistory(from startDate: Date?, endDate: Date?, limit: NSNumber?, onSuccess: Handler<[HealthkitWorkout]>?, onError: Handler<Error>?) {
        let type = HKSampleType.workoutType()
        var predicate : NSPredicate?
        var sortDescriptios : [NSSortDescriptor]?
        if let startDate = startDate {
            let end = endDate ?? Date()
            predicate = HKQuery.predicateForSamples(withStart: startDate, end: end, options: [])
            sortDescriptios = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        } else if let endDate = endDate {
            predicate = HKQuery.predicateForSamples(withStart: nil, end: endDate, options: [])
            sortDescriptios = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        }
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit?.intValue ?? 0, sortDescriptors:sortDescriptios) { (_, results, error) in
            if let error = error {
                onError?(error)
            } else if let workouts = results as? [HealthkitWorkout] {
                onSuccess?(workouts)
            }
        }
        self.healthKitStore.execute(query)
    }

    private func saveWorkout(saveInfo: SaveWorkoutInfo,
                             completionHandler: @escaping (Bool, Error?) -> Void) {

        if self.canSaveWorkouts {
            self.saveWorkoutThenAppendProperties(saveInfo: saveInfo,
                                                 completionHandler: completionHandler)
        } else {
            self.saveIndependentProperties(heartRateInfo: saveInfo.heartRate,
                                           totalEnergyBurned: saveInfo.totalEnergyBurned,
                                           startDate: saveInfo.start,
                                           endDate: saveInfo.end,
                                           completionHandler: completionHandler)
        }
    }

    private var canSaveWorkouts : Bool {
        return self.authorizationStatus(type: HealthKitWriteAttribute.workout) == .sharingAuthorized
    }

    private var canSaveHeartRate : Bool {
        return self.authorizationStatus(type: HealthKitWriteAttribute.heartRate) == .sharingAuthorized
    }

    private var canSaveActiveEnergy : Bool {
        return self.authorizationStatus(type: HealthKitWriteAttribute.activeEnergy) == .sharingAuthorized
    }

    typealias SaveWorkoutInfo = ( activityType: HKWorkoutActivityType,
        start: Date,
        end: Date,
        duration: TimeInterval,
        totalEnergyBurned: HKQuantity?,
        totalDistance: HKQuantity?,
        device: HKDevice?,
        metadata: [String : Any]?,
        heartRate: HealthKitHeartRateInfo?)

    private func saveWorkoutThenAppendProperties(saveInfo: SaveWorkoutInfo,
                                                 completionHandler: @escaping (Bool, Error?) -> Void) {

        let workout = self.workoutToSave(saveInfo: saveInfo,
                                         metadata: saveInfo.metadata)

        self.save(object: workout) {[weak self] (success, error) in

            if success {
                self?.appendProperties(healdKitPropertyInfo: (workout: workout,
                                                              heartRateInfo: saveInfo.heartRate,
                                                              totalEnergyBurned: saveInfo.totalEnergyBurned,
                                                              start: saveInfo.start,
                                                              end: saveInfo.end),
                                       completionHandler: completionHandler)
            } else {
                completionHandler(success, error)
            }
        }

    }

    typealias HealthKitProperty = (workout: HKWorkout,
        heartRateInfo: HealthKitHeartRateInfo?,
        totalEnergyBurned: HKQuantity?,
        start: Date,
        end: Date)

    private func appendProperties(healdKitPropertyInfo: HealthKitProperty,
                                  completionHandler: @escaping (Bool, Error?) -> Void) {

        var samples : [HKQuantitySample] = []

        if let heartRateToSave = self.heartRateToSave(fromHeartRateInfo: healdKitPropertyInfo.heartRateInfo) {
            samples.append(heartRateToSave)
        }

        if let activeEnergyToSave = self.activeEnergyToSave(fromEnergyBurned: healdKitPropertyInfo.totalEnergyBurned,
                                                            start: healdKitPropertyInfo.start,
                                                            end: healdKitPropertyInfo.end) {
            samples.append(activeEnergyToSave)
        }

        self.addSamples(samples,
                        toWorkout: healdKitPropertyInfo.workout,
                        completionHandler: completionHandler)

    }

    private func heartRateToSave(fromHeartRateInfo hearRateInfo: HealthKitHeartRateInfo?) -> HKQuantitySample? {

        if self.canSaveHeartRate {
            if let heartRateQuantitySample = self.heartRateQuantitySample(fromHeartRateInfo: hearRateInfo) {
                return heartRateQuantitySample
            }
        }

        return nil
    }

    private func activeEnergyToSave(fromEnergyBurned energyBurned: HKQuantity?, start: Date, end: Date) -> HKQuantitySample? {

        if self.canSaveActiveEnergy {
            if let totalEnergyBurnedQuantity = energyBurned,
                let activeEnergyQuantitySample = self.activeEnergyQuantitySample(totalEnergyBurned: totalEnergyBurnedQuantity,
                                                                                 startDate: start,
                                                                                 endDate: end) {
                return activeEnergyQuantitySample
            }
        }

        return nil
    }

    private func addSamples(_ samples: [HKQuantitySample], toWorkout workout: HKWorkout,  completionHandler: @escaping (Bool, Error?) -> Void) {
        self.healthKitStore.add(samples, to: workout, completion: completionHandler)
    }

    private func saveIndependentProperties(heartRateInfo: HealthKitHeartRateInfo?, totalEnergyBurned:HKQuantity?, startDate: Date, endDate: Date, completionHandler: @escaping (Bool, Error?) -> Void) {

        var objectsToSave : [HKObject] = []

        if let activeEnergyToSave = self.activeEnergyToSave(fromEnergyBurned: totalEnergyBurned, start: startDate, end: endDate) {
            objectsToSave.append(activeEnergyToSave)
        }

        if let heartRateToSave = self.heartRateToSave(fromHeartRateInfo: heartRateInfo) {
            objectsToSave.append(heartRateToSave)
        }

        self.save(objects: objectsToSave, completionHandler: completionHandler)

    }

    private func heartRateQuantitySample(fromHeartRateInfo heartRateInfo: HealthKitHeartRateInfo?) -> HKQuantitySample? {

        if let heartRateWorkout = heartRateInfo, let heartRateQuantitySample = self.quantitySample(forHeartRate: heartRateWorkout) {
            return heartRateQuantitySample
        }

        return nil
    }

    func activeEnergyQuantitySample(totalEnergyBurned: HKQuantity, startDate: Date, endDate: Date) -> HKQuantitySample? {

        guard let activeEnergyType : HKQuantityType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) else {
            return nil
        }

        return HKQuantitySample(type: activeEnergyType,
                                quantity: totalEnergyBurned,
                                start: startDate,
                                end:endDate)

    }

    func workoutToSave(saveInfo: SaveWorkoutInfo,
                       metadata: [String : Any]?) -> HKWorkout {

        return HKWorkout(activityType: saveInfo.activityType,
                         start: saveInfo.start,
                         end: saveInfo.end,
                         duration: saveInfo.duration,
                         totalEnergyBurned: saveInfo.totalEnergyBurned,
                         totalDistance: saveInfo.totalDistance,
                         device: saveInfo.device,
                         metadata: metadata)
    }

    public func save(heartRate: HealthKitHeartRateInfoObjc, onSuccess: Handler<Bool>?, onError: Handler<Error>?) {

        let heartRateQuantity = HKQuantity(unit: UnitHealthKit.heartRate,
                                           doubleValue: heartRate.accHeartRate)

        guard let heartRateType : HKQuantityType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            onError?(HealthKitError.heartRateType)
            return
        }

        let heartSample = HKQuantitySample(type: heartRateType,
                                           quantity: heartRateQuantity,
                                           start: heartRate.startDate,
                                           end: heartRate.endDate)

        self.save(object: heartSample, completionHandler:  {(success, error) in
            if let error = error {
                onError?(error)
            } else {
                onSuccess?(success)
            }
        })
    }

    func quantitySample(forHeartRate heartRate: HealthKitHeartRateInfo) -> HKQuantitySample? {
        let heartRateQuantity = HKQuantity(unit: UnitHealthKit.heartRate,
                                           doubleValue: heartRate.avgHeartRate)

        guard let heartRateType : HKQuantityType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            return nil
        }

        return HKQuantitySample(type: heartRateType,
                                quantity: heartRateQuantity,
                                start: heartRate.startDate,
                                end: heartRate.endDate)
    }

    func save(object: HKObject, completionHandler: @escaping (Bool, Error?) -> Void) {
        self.healthKitStore.save(object,withCompletion:completionHandler)
    }

    func save(objects: [HKObject], completionHandler: @escaping (Bool, Error?) -> Void) {
        self.healthKitStore.save(objects,withCompletion:completionHandler)
    }

    public func startWorkoutOnWatch(type: HKWorkoutActivityType, onSuccess: Action?, onError: Handler<Error>?) {

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type
        configuration.locationType = .indoor
        self.healthKitStore.startWatchApp(with: configuration, completion:  {(success, error) in
            if let error = error {
                onError?(error)
            } else {
                onSuccess?()
            }
        })
    }
}

public enum HealthKitError: Error {
    case quantityTypeIdentifierUnknown
    case nilYear
    case heartRateType
    case error(Error)
    
    public var debugDescription: String {
        switch self {
        case .quantityTypeIdentifierUnknown:
            return "Unknown type Identifier."
        case .nilYear:
            return "year is nil"
        case .heartRateType:
            return "Not HKQuantityType for HKQuantityTypeIdentifier.heartRate"
        default:
            return self.localizedDescription
        }
    }
}

struct UnitHealthKit {
    static let heartRate = HKUnit.init(from: "count/min")
    static let kilocalorie = HKUnit.kilocalorie()
}
