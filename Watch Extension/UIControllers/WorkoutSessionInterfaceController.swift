//
//  WorkoutSessionInterfaceController.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import WatchKit
import Foundation
import HealthKit


class WorkoutSessionInterfaceController: WKInterfaceController {

    @IBOutlet weak var activeCaloriesLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var playBtn: WKInterfaceButton!
    @IBOutlet weak var pauseBtn: WKInterfaceButton!
    @IBOutlet weak var discardBtn: WKInterfaceButton!
    @IBOutlet weak var endBtn: WKInterfaceButton!
    
    private var healthKit : HealthKit = Current.toolbox.healthKit()
    private var phoneApp : PhoneApp = Current.toolbox.phoneApp()
    
    private var currentSessionState : HKWorkoutSessionState?
    private var datePaused: Date?
    private var needsToPauseSessionWhenStartRunning: Bool = false
    private var originalStartDate: Date!
    private var startedDate: Date = Date()
    private var startedIntervalDate: Date = Date()
    private var currentBlockDuration: Int = 0
    private var timePaused: TimeInterval! = 0
    private var timerForUpdateProgress:Timer? = Timer()
    private var totalCaloriesBurned: Int = 0
    private var workoutDuration: Int? = nil

    //MARK: - lifecycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        self.phoneApp.delegate = self

        healthKit.setSessionDelegate(delegate:  self)
        healthKit.setBuilderDelegate(delegate:  self)
        self.pauseBtn.setEnabled(true)
        self.playBtn.setEnabled(false)
        self.originalStartDate = self.startedDate
        self.currentSessionState = nil
        DispatchQueue.main.async {
            self.healthKit.startWorkout() { [weak self] result in
                if !result.isSuccess {
                    Router.displayAlert(action: .startWorkout, from: self)
                }
            }
            self.listenNotifications()
        }
    }

    deinit {
        self.phoneApp.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }

    override func willActivate() {
        super.willActivate()
    }

    private func listenNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(endWorkout),
                                               name: Notifications.didFinishWorkout.name,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(pauseWorkout),
                                               name: Notifications.didPauseWorkout.name,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(resumeWorkout),
                                               name: Notifications.didResumeWorkout.name,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateState),
                                               name: Notifications.didUpdateState,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(discardWorkout),
                                               name: Notifications.didDiscardWorkout.name,
                                               object: nil)

    }

    @IBAction func end() {
        Notifications.didFinishWorkout.post()
        self.phoneApp.finishWorkout()

    }
    @IBAction func discard() {
        Notifications.didDiscardWorkout.post()
        self.phoneApp.discardWorkout()

    }
    @IBAction func pause() {
        Notifications.didPauseWorkout.post()
        self.phoneApp.pauseWorkout()

    }
    @IBAction func play() {
        Notifications.didResumeWorkout.post()
        self.phoneApp.resumeWorkout()

    }
    @objc private func updateState(notification: Notification) {
        guard let state : WorkoutState =  notification.object as? WorkoutState else {return}
    }

    // MARK: - State Control

    @objc private func pauseWorkout() {
        if self.sessionIsRunning {
            healthKit.pauseWorkout()
            self.pauseBtn.setEnabled(false)
            self.playBtn.setEnabled(true)
            self.needsToPauseSessionWhenStartRunning = false
        } else {
            self.needsToPauseSessionWhenStartRunning = true
        }
    }
    
    @objc private func resumeWorkout() {
        self.pauseBtn.setEnabled(true)
        self.playBtn.setEnabled(false)
        if !self.sessionIsRunning {
            self.needsToPauseSessionWhenStartRunning = false
            healthKit.resumeWorkout()
        }
    }


    @objc private func discardWorkout() {
        self.needsToPauseSessionWhenStartRunning = false
        healthKit.discardWorkout()
        Router.openWelcomeScreen()
    }
    
    @objc private func endWorkout() {
        self.needsToPauseSessionWhenStartRunning = false
        healthKit.endWorkOut { [weak self] result in
            if !result.isSuccess {
                Router.displayAlert(action: .endWorkout, from: self)
            } else {
                self?.goToSummaryScreen()
            }
        }
    }

    //MARK: - private

    private var sessionIsRunning: Bool {
        return self.currentSessionState == HKWorkoutSessionState.running
    }

    private func goToSummaryScreen() {
        self.healthKit.getAVGHeartRate(since: self.originalStartDate, to: Date()) { (avgHeartRate, _) in
            let summaryInfo = WorkoutSummary(caloriesBourned: self.totalCaloriesBurned,
                                             avgHeartRate: avgHeartRate)
            Router.openWorkoutSummaryScreen(with:summaryInfo)
        }
    }

}
extension TimeInterval {
    var formattedInMinutesAndSeconds: String {
        var elapsedTime = self
        //calculate the minutes in elapsed time.
        let minutes = Int(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        //calculate the seconds in elapsed time.
        let seconds = Int(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        return "\(strMinutes):\(strSeconds)"
    }
}

//MARK: - HKLiveWorkoutBuilderDelegate

extension WorkoutSessionInterfaceController: HKLiveWorkoutBuilderDelegate {

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            let statistics = workoutBuilder.statistics(for: quantityType)
            let label = labelForQuantityType(quantityType)

            update(label:label, withStatistics: statistics)
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        //Do nothing, because we are not adding new events to the builder
    }

    // MARK: - Update the interface

    private func update(label: WKInterfaceLabel?, withStatistics statistics: HKStatistics?) {
        // Make sure we got non `nil` parameters.
        guard let label = label, let statistics = statistics else {
            return
        }

        // Dispatch to main, because we are updating the interface.
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case .heartRate:
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                guard let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) else {return}
                let roundedValue = Int(round(value))
                label.setText("\(roundedValue)")
                self.phoneApp.send(heartRate: roundedValue)
            case .activeEnergy:
                let energyUnit = HKUnit.kilocalorie()
                guard let value = statistics.sumQuantity()?.doubleValue(for: energyUnit) else {return}
                let roundedValue = Int( round(value) )
                self.totalCaloriesBurned = roundedValue
                label.setText("\(roundedValue)")
                self.phoneApp.send(calories: roundedValue)
                return
            default:
                return
            }
        }
    }

    private func labelForQuantityType(_ type: HKQuantityType) -> WKInterfaceLabel? {
        switch type {
        case .heartRate:
            return heartRateLabel
        case .activeEnergy:
            return activeCaloriesLabel
        default:
            return nil
        }
    }
}

//MARK: - HKWorkoutSessionDelegate

extension WorkoutSessionInterfaceController: HKWorkoutSessionDelegate {

    func workoutSession( _ workoutSession: HKWorkoutSession,
                         didChangeTo toState: HKWorkoutSessionState,
                         from fromState: HKWorkoutSessionState,
                         date: Date) {
        DispatchQueue.main.async {
            self.checkSessionState(toState)
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        Router.displayAlert(action: .workOutError, from: self)
    }

    private func checkSessionState(_ state: HKWorkoutSessionState) {
        self.currentSessionState = state
        if self.needsToPauseSessionWhenStartRunning && state == .running {
            self.healthKit.pauseWorkout()
            self.needsToPauseSessionWhenStartRunning = false
        }
    }

}

//MARK: - PhoneManagerDelegate

extension WorkoutSessionInterfaceController: PhoneAppDelegate {
    func didPauseWorkout() {
        Notifications.didPauseWorkoutOnPhone.post()
        self.pauseWorkout()
    }

    func didResumeWorkout() {
        Notifications.didResumeWorkoutOnPhone.post()
        self.resumeWorkout()
    }

    func didStopWorkout() {
        Notifications.didFinishWorkoutOnPhone.post()
        self.endWorkout()
    }

    func didDiscardWorkout() {
        self.discardWorkout()
    }

    func didStartWorkout(withDuration duration: Int?, startedDate: Date?) {
        //
    }
}
