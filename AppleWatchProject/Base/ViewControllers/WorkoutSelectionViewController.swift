//
//  WorkoutSelectionViewController.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 05/01/2021.
//

import Foundation
import UIKit
import HealthKit
import RxSwift
import RxCocoa
class WorkoutSelectionViewController: BaseViewController {
    @IBOutlet weak var workoutsTableview: UITableView!
    private var healthKit : HealthKit = Current.healthkit()
    private var appleWatch : AppleWatch = Current.appleWatch()
    private let workoutActivityTypes: [HKWorkoutActivityType] = [.running, .dance, .walking, .mixedCardio, .coreTraining, .cycling]
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "History", style: .done, target: self, action: #selector(openWorkoutHistory))

        self.configureTableView()
        self.appleWatch.initializeIfNeededBeforeWorkoutStarts()
    }
    
    private func configureTableView() {
        workoutsTableview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let items = Observable.just(
            self.workoutActivityTypes.map {$0.activityName}
        )
        items
            .bind(to: workoutsTableview.rx.items(cellIdentifier: "Cell",
                                                 cellType: UITableViewCell.self)) { (row, workoutActivityTypeName, cell) in
                                                                                     cell.textLabel?.text = workoutActivityTypeName
                                                                                    }
            .disposed(by: disposeBag)
        
        workoutsTableview.rx
            .modelSelected(String.self)
            .subscribe(onNext:  { [unowned self] seletedActivityName in
                self.startWorkout(with: seletedActivityName)
            })
            .disposed(by: disposeBag)
    }
    
    private func startWorkout(with workoutActivityTypeName: String) {
        if self.appleWatch.isWatchAppInstalled {
            let activityType = HKWorkoutActivityType.type(from: workoutActivityTypeName)
            self.healthKit.startWorkoutOnWatch(type: activityType) { [weak self] in
                DispatchQueue.main.async {
                    self?.goToWorkoutSession()
                }
            } onError: { [weak self](error) in
                self?.showErrorStartingWorkoutOnWatch(error)
            }
        }
    }
    private func showErrorStartingWorkoutOnWatch(_ error: Error) {
        let alertController = UIAlertController.init(title: "Error starting workout on watch", message:error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        self.present(alertController, animated: false)
    }
    private func goToWorkoutSession() {
        let workoutSessionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkoutSessionViewController") as UIViewController
        self.navigationController?.pushViewController(workoutSessionViewController, animated: false)
    }
    @objc func openWorkoutHistory(sender: UIBarButtonItem) {
        let workoutSessionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkoutsHistoryViewController") as UIViewController
        self.navigationController?.pushViewController(workoutSessionViewController, animated: false)
    }

}
