//
//  WorkoutSessionViewController.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 07/02/2021.
//

import Foundation
import HealthKit
import RxSwift
import RxCocoa
class WorkoutSessionViewController: BaseViewController {
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var discardBtn: UIButton!
    private lazy var appleWatch : AppleWatch = Current.appleWatch()
    private var currentWorkoutState: WorkoutState = .init(action: .started, source: .watch)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateWorkoutState(state: self.currentWorkoutState)
        self.bindCaloriesAndHeartRateFromWtach()
        self.bindMessagesFromWatch()
        self.bindActionButtons()
    }
    
    // MARK: Private
    private var caloriesBinder : Binder<Int> {
        return Binder(self) { (vc, calories) in
            vc.caloriesLabel.text = "\(calories) Calories Burned"
        }
    }
    
    private var heartRateBuinder : Binder<Int> {
        return Binder(self) { (vc, heartRate) in
            vc.heartRateLabel.text = "\(heartRate) BPM"
        }
    }
    
    private func bindCaloriesAndHeartRateFromWtach() {
        self.appleWatch.caloriesDriver
            .drive(self.caloriesBinder)
            .disposed(by: self.disposeBag)

        self.appleWatch.heartRateDriver
            .drive(self.heartRateBuinder)
            .disposed(by: self.disposeBag)
    }
    private func bindActionButtons() {
        self.playBtn.rx.tap.asObservable()
            .subscribeNext(weak: self, WorkoutSessionViewController.resumeWorkoutOnWatch)
            .disposed(by: disposeBag)
    
        self.pauseBtn.rx.tap.asObservable()
            .subscribeNext(weak: self, WorkoutSessionViewController.pauseWorkoutOnWatch)
            .disposed(by: disposeBag)
    
        self.discardBtn.rx.tap.asObservable()
            .subscribeNext(weak: self, WorkoutSessionViewController.discardWorkoutOnWatch)
            .disposed(by: disposeBag)
    
        self.endBtn.rx.tap.asObservable()
            .subscribeNext(weak: self, WorkoutSessionViewController.saveWorkoutOnWatch)
            .disposed(by: disposeBag)
    }
    private func bindMessagesFromWatch() {
        self.appleWatch.workoutState.asObservable()
            .subscribeNext(weak: self, WorkoutSessionViewController.updateWorkoutState)
            .disposed(by: self.disposeBag)
    }
    private func updateWorkoutState(state: WorkoutState) {
        guard state.source == .watch else {return}
        self.currentWorkoutState = state
        switch state.action {
        case .started:
            self.configureStartedState()
        case .resumed:
            self.configureResumedState()
        case .paused:
            self.configurePausedState()
        case .discarded:
            self.userDiscardedWorkoutOnWatch()
        case .saved:
            self.userEndedWorkoutOnWatch()
        }

      }
    private func configureStartedState() {
        self.playBtn.isEnabled = false
        self.pauseBtn.isEnabled = true
    }
    private func configurePausedState() {
        self.playBtn.isEnabled = true
        self.pauseBtn.isEnabled = false
    }
    private func configureResumedState() {
        self.playBtn.isEnabled = false
        self.pauseBtn.isEnabled = true

    }
    private func userDiscardedWorkoutOnWatch() {
        
    }
    private func userEndedWorkoutOnWatch() {
        
    }
    
    private func resumeWorkoutOnWatch() {
        if self.appleWatch.isActive {
            self.configureResumedState()
            self.appleWatch.appDidResumeWorkout()
        }
    }
    
    private func pauseWorkoutOnWatch() {
        if self.appleWatch.isActive {
            self.configurePausedState()
            self.appleWatch.appDidPauseWorkout()
        }
    }
    
    private func discardWorkoutOnWatch() {
        if self.appleWatch.isActive {
            self.appleWatch.appDidDiscardWorkout()
            self.navigationController?.popViewController(animated: true)
        }
    }
    private func saveWorkoutOnWatch() {
        if self.appleWatch.isActive {
            self.appleWatch.appDidSaveWorkout()
        }
    }
}
