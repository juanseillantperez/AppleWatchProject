//
//  HealthKitManager.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import HealthKit

class HealthKitManager: NSObject, HealthKit {

    private var builder: HKLiveWorkoutBuilder?
    private var configuration = HKWorkoutConfiguration()
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private let toRead : Set<HKSampleType> = [ HKQuantityType.heartRate, HKQuantityType.activeEnergy, .workouts]
    private let toShare : Set<HKSampleType> = [ HKQuantityType.heartRate, HKQuantityType.activeEnergy, .workouts]

    private weak var builderDelegate: HKLiveWorkoutBuilderDelegate? {
        didSet {
            self.builder?.delegate = builderDelegate
        }
    }

    private weak var sessionDelegate: HKWorkoutSessionDelegate? {
        didSet {
            self.session?.delegate = sessionDelegate
        }
    }

    //MARK: - lifecycle

    override init() {
        configuration.activityType = .mixedCardio
        configuration.locationType = .indoor
    }

    func initialize(completion: @escaping CompletionHandler) {

        healthStore.requestAuthorization(toShare: toShare,
                                         read: toRead,
                                         completion: handler(from: completion))
    }

    func hasAuthorizationToShare() -> Bool {
        let typeSharedUnauthorized = toShare.first(where: { (type) -> Bool in
            healthStore.authorizationStatus(for: type) != .sharingAuthorized
        })
        return typeSharedUnauthorized == nil
    }
    //MARK: - public

    func setConfiguration(_ configuration: HKWorkoutConfiguration) {
        self.configuration = configuration
    }

    func setSessionDelegate(delegate: HKWorkoutSessionDelegate?) {
        self.sessionDelegate = delegate
    }

    func setBuilderDelegate(delegate: HKLiveWorkoutBuilderDelegate?) {
        self.builderDelegate = delegate
    }
    
    func workoutHistory(completionHandler: @escaping ([HKWorkout]?, Error?) -> Void) {
        let type = HKSampleType.workoutType()
        let predicate  = HKQuery.predicateForObjects(from: HKSource.default())
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors:nil) { (_, results, error) in
            completionHandler(results as? [HKWorkout], error)
        }
        self.healthStore.execute(query)
    }
    
    func getAVGHeartRate(since:Date, to end: Date, completionHandler: @escaping (Double?, Error?) -> Void){
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
        self.healthStore.execute(query)
    }

    func startWorkout(completion: @escaping CompletionHandler) {
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            completion(.failure(HealthKitError.unableToStartWorkout))
            return
        }
        guard let builder = self.builder else {
            completion(.failure(HealthKitError.unableToStartWorkout))
            return
        }
        guard let session = self.session else {
            completion(.failure(HealthKitError.unableToStartWorkout))
            return
        }

        // Setup session and builder.
        session.delegate = sessionDelegate
        builder.delegate = builderDelegate

        let dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                 workoutConfiguration: configuration)
        builder.dataSource = dataSource

        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date(), completion: handler(from: completion))
    }

    func pauseWorkout() {
        session?.pause()
    }

    func resumeWorkout() {
        session?.resume()
    }

    func endWorkOut(completion:  @escaping CompletionHandler) {
        session?.end()

        builder?.endCollection(withEnd: Date(), completion: handler(from: completion))
    }

    func discardWorkout() {
        session?.end()
        builder?.discardWorkout()
    }
}

//MARK: - helpers

func handler(from resultHandler: @escaping CompletionHandler) -> (Bool, Error?) -> Void {
    return  { success, error in
        if let error = error {
            resultHandler(.failure(error))
        } else {
            resultHandler(.success)
        }
    }
}

enum HealthKitError : Error {
    case unableToStartWorkout
}
extension HKQuantityType {
    static var heartRate : HKQuantityType {
        HKQuantityType.quantityType(forIdentifier: .heartRate)!
    }

    static var activeEnergy : HKQuantityType {
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    }
  
}
extension HKSampleType {
  static var workouts : HKSampleType {
    HKSampleType.workoutType()
  }
}
