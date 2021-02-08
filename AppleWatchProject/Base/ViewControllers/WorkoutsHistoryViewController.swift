//
//  WorkoutsHistoryViewController.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 08/02/2021.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import HealthKit
class WorkoutsHistoryViewController: BaseViewController {
    @IBOutlet weak var historyTableView: UITableView!
    private var healthKit : HealthKit = Current.healthkit()
    private var hkWorkoutsRelay: PublishRelay<[HealthkitWorkout]> = PublishRelay()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.getWorkoutsFromHealthkit()
    }
    private var cellModels : Driver<[HealthkitWorkout]> {
        return self.hkWorkoutsRelay
            .asDriverOrNever()
    }

    private func configureTableView() {
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        self.cellModels.asObservable()
            .bind(to: historyTableView.rx.items(cellIdentifier: "Cell",
                                                 cellType: UITableViewCell.self)) { (row, workoutActivityTypeName, cell) in
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = workoutActivityTypeName.infoToDisplay
                cell.textLabel?.sizeToFit()
                                                                                    }
            .disposed(by: disposeBag)
        
        historyTableView.rx
            .modelSelected(HealthkitWorkout.self)
            .subscribe(onNext:  { [unowned self] workoutSelected in
                self.getAVGHeartRate(for: workoutSelected)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func getWorkoutsFromHealthkit() {
        self.healthKit.workoutHistory(from: nil, endDate: Date(), limit: 100) { [weak self] (workoutsFromHealthKit) in
            self?.hkWorkoutsRelay.accept(workoutsFromHealthKit)
        } onError: { (error) in
            self.showError(error: error, title: "Error getting history from HealthKit")

        }
    }
    private func getAVGHeartRate(for workout: HealthkitWorkout) {
        self.healthKit.getAVGHeartRate(since: Date(timeIntervalSince1970: workout.startInt), toEndDate: Date(timeIntervalSince1970: workout.stopInt)) { (avgHeartRate, error) in
            if let error = error {
                self.showError(error: error, title: "Error getting AVG Heart Rate for \(workout.name)")
            } else if let avgHeartRate = avgHeartRate {
                self.showHeartRate(for: workout, avgHeartRate: avgHeartRate)
            }
        }
    }
    private func showError(error: Error, title: String) {
        let alertController = UIAlertController.init(title: title, message:error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async {
            self.present(alertController, animated: false)
        }
    }
    
    private func showHeartRate(for workout: HealthkitWorkout, avgHeartRate: Double) {
        let alertController = UIAlertController.init(title: "AVG Heart Rate for \(workout.name)", message:"\(avgHeartRate)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async {
            self.present(alertController, animated: false)
        }
    }
}

extension HealthkitWorkout {
    var infoToDisplay: String {
        var info : String = ""
        info.append("Name: \(self.name) \n")
        info.append("App: \(self.sourceApp) \n")
        info.append("Calories: \(self.calories) \n")
        info.append("Distance in Miles: \(self.distance) \n")
        return info
    }
}
