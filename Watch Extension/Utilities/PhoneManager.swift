//
//  PhoneManager.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import WatchConnectivity
import WatchKit
import HealthKit


class PhoneManager: NSObject, PhoneApp {
    weak var delegate: PhoneAppDelegate?
    
    func initialize() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendLaunchMessages() {
        self.sendMessage(LaunchMessage(message: .launch).dictionary)
    }
    
    func send(calories: Int) {
        self.sendMessage(CaloriesSensorData(calories: calories).dictionary)
    }

    func send(heartRate: Int) {
        self.sendMessage(HeartRateSensorData(heartRate: heartRate).dictionary)
    }
        
    func resumeWorkout() {
        self.sendMessage(WorkoutState(action: .resumed, source: .watch).dictionary)
    }
    
    func sendUserHasDecidedPermisionsFlag() {
        self.sendMessage(HKPermissionBeDecidedData(beDecided: true).dictionary)
    }
    
    func pauseWorkout() {
        self.sendMessage(WorkoutState(action: .paused, source: .watch).dictionary)
    }
    
    func finishWorkout() {
        self.sendMessage(WorkoutState(action: .saved, source: .watch).dictionary)
    }
    func discardWorkout() {
        self.sendMessage(WorkoutState(action: .discarded, source: .watch).dictionary)
    }
    func sendMessage(_ message: [String: Any]) {
        let session = WCSession.default
        if session.activationState == .activated  && session.isReachable {
            session.sendMessage(message, replyHandler: nil) { (error) in
                print("-----WATCH FAILS TO SEND MESSAGE WITH ERROR \(error)")
            }
        } else {
            print("session: \(session)")
        }
    }
}

extension PhoneManager: WCSessionDelegate {

    // MARK: - WCSessionDelegate
    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {
        print("WCSession activationDidCompleteWith state: \(activationState)")
    }


    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("WCSession didReceiveMessage \(message)")
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("WCSession didReceiveApplicationContext \(applicationContext)")
        self.didReceiveApplicationContext(applicationContext)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("WCSession didReceiveUserInfo \(userInfo)")
    }
    public func sessionReachabilityDidChange(_ session: WCSession) {
        print("WCSession sessionReachabilityDidChange: \(session.isReachable)")
    }

    func didReceiveApplicationContext(_ message: [String: Any]) {
        DispatchQueue.main.async {
            if let state = try? WorkoutState(dictionary: message) {
                switch state.action {
                case .started:
                    self.delegate?.didStartWorkout(withDuration: state.durationInSeconds, startedDate: state.startedDate)
                case .saved :
                    self.delegate?.didStopWorkout()
                case .discarded :
                    self.delegate?.didDiscardWorkout()
                case .paused :
                    self.delegate?.didPauseWorkout()
                case .resumed :
                    self.delegate?.didResumeWorkout()
                }
            }
        }
    }
}

extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}

extension Decodable {
    init(dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Self.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}
