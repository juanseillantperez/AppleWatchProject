//
//  AppleWatchManager.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import WatchConnectivity
import RxSwift
import RxCocoa
public class AppleWatchManager: NSObject, AppleWatch {
    private(set) public var calories: Int = 0
    private(set) public var heartRate : Int = 0
    private var caloriesRelay : PublishRelay<Int> = PublishRelay()
    private var heartRateRelay : PublishRelay<Int> = PublishRelay()
    private var workoutStateRelay : PublishRelay<WorkoutState> = PublishRelay()

    //MARK: - lifecycle
        
    //MARK: - public
    public var caloriesDriver : Driver<Int> {
        caloriesRelay.asDriverOrNever()
    }

    public var heartRateDriver : Driver<Int> {
        heartRateRelay.asDriverOrNever()
    }

    public var workoutState: Driver<WorkoutState> {
        workoutStateRelay.asDriverOrNever()
    }
    public var isActive : Bool {
        let paired = session?.isPaired == true
        let activated = session?.activationState == .activated
        let installed =  session?.isWatchAppInstalled == true
        return paired && activated && installed
    }
    
    public var isWatchAppInstalled : Bool {
        session?.isWatchAppInstalled == true
    }
    
    public var isSupported: Bool {
        return self.session != nil
    }
    
    /// You must call
    public func initialize() {
        self.session?.delegate = self
        self.session?.activate()
    }
    
    public func initializeIfNeededBeforeWorkoutStarts() {
        if self.session?.delegate == nil {
            self.session?.delegate = self
        }
        if self.session?.activationState == .notActivated {
            self.session?.activate()
        }
    }
    
    public func appDidDiscardWorkout() {
        self.updateApplicationContextWith(action: .discarded)
    }
    
    public func appDidSaveWorkout() {
        self.updateApplicationContextWith(action: .saved)
    }
    
    public func appDidPauseWorkout() {
        self.updateApplicationContextWith(action: .paused)
    }
    
    public func appDidResumeWorkout() {
        self.updateApplicationContextWith(action: .resumed)
    }
    
    public func appDidStartWorkout(withDuration durationInSeconds: Int, startedDate: Date) {
        self.updateApplicationContextWith(action: .started,
                                          workoutDuration: durationInSeconds,
                                          startedDate: startedDate)
    }

    public func applicationWillTerminate() {
        if self.isActive {
            self.appDidDiscardWorkout()
        }
    }
    
    public func healthKitPermissionsDidChange() {
        self.updateApplicationContextWith(message: MessageForWatch(message: AppMessage.healthKitPermissionsDidChange))
    }
    
    public func needsToDismissSummaryScreen() {
        self.updateApplicationContextWith(message: MessageForWatch(message:AppMessage.needsToDismissSummaryScreen))
    }
    
    //MARK: - private
    
    private var session : WCSession? {
        guard WCSession.isSupported() else { return nil }
        return WCSession.default
    }
    
    private func send(message: WorkoutState) {
        let session = WCSession.default
        if session.activationState == .activated  && session.isReachable {
            session.sendMessage(message.dictionary, replyHandler: nil, errorHandler: nil)
        }
    }
    
    private func updateApplicationContextWith(action: AppleWatchWorkoutAction,
                                              workoutDuration: Int? = nil,
                                              currentElapsedTime: Double? = nil,
                                              startedDate: Date? = nil) {
        let message = WorkoutState(action: action,
                                   source: .phone,
                                   durationInSeconds: workoutDuration,
                                   startedDate:startedDate)
        updateApplicationContextWith(message: message)
    }
    
    private func updateApplicationContextWith<T: Encodable>(message: T) {
        let session = WCSession.default
        if session.activationState == .activated {
            do {
                try session.updateApplicationContext(message.dictionary)
            } catch {
                //Do nothing
            }
        }
    }
    
    private func didReceiveData(message: [String : Any]) {
        DispatchQueue.main.async {
            
            if let launchMessage = try? LaunchMessage(dictionary: message) {
                self.trackMessage(launchMessage: launchMessage)
            }
            
            if let heartRateData = try? HeartRateSensorData(dictionary: message) {
                self.heartRateRelay.accept(heartRateData.heartRate)
            }
            
            if let caloriesData = try? CaloriesSensorData(dictionary: message) {
                self.caloriesRelay.accept(caloriesData.calories)
            }
            
            if let workoutState = try? WorkoutState(dictionary: message) {
                self.workoutStateRelay.accept(workoutState)
            }
            
            if (try? HKPermissionBeDecidedData(dictionary: message)) != nil {

            }
        }
    }
    
    private func trackMessage(launchMessage: LaunchMessage) {
        if !self.installMessageWasSent {
        }
    }
    
    private var installMessageWasSent: Bool {
        return false
    }
}

// MARK: - WCSessionDelegate

extension AppleWatchManager: WCSessionDelegate {
    
    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {
        print("activationDidCompleteWith \(activationState)")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print(message)
        self.didReceiveData(message: message)
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
    }
    
}
