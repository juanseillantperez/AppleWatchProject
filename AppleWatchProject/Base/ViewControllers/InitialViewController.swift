//
//  ViewController.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import UIKit
import RxSwift
import RxSwiftExt
import HealthKit
class InitialViewController: BaseViewController {
    @IBOutlet weak var requestHealthKitAccessBtn: UIButton!
    private var healthKit : HealthKit = Current.healthkit()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationItem.hidesBackButton = true
        self.configureRequestHealthKitAccessBtn()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.healthKit.authorizationStatus(type: HealthKitWriteAttribute.workout.objc) == .sharingAuthorized {
            self.goToWorkoutSelection()
        }
    }
    private func configureRequestHealthKitAccessBtn() {
        self.requestHealthKitAccessBtn.rx.tap.asObservable()
            .subscribeNext(weak: self, InitialViewController.requestAccessToHealthkit)
            .disposed(by: disposeBag)
    }

    private func requestAccessToHealthkit() {
        let toWrite : [HealthKitWriteAttribute] = [.workout, .activeEnergy, .heartRate]
        let toRead : [HealthKitReadAttribute] = [.workout, .activeEnergy, .heartRate]
        self.healthKit.requestAuthorizationTo(write: toWrite.map{$0.objc},
                                              read: toRead.map{$0.objc}) { (success, error) in
            if success {
                self.goToWorkoutSelection()
            }
        }
    }
    
    private func goToWorkoutSelection() {
        let workoutSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorkoutSelectionViewController") as UIViewController
        self.navigationController?.pushViewController(workoutSelectionViewController, animated: false)
    }
}


public extension ObservableType {
    func subscribeNext<A>(weak obj: A, _ onNext: @escaping (A) -> () -> Void) -> Disposable where A : AnyObject {
        return self.subscribe(onNext: { [weak obj](_) in
            guard let obj = obj else {return}
            onNext(obj)()
        })
    }
    func subscribeNext(probe:@escaping Handler<Self.Element>) -> Disposable {
        return self.subscribe(onNext: probe)
    }
    func doOnNext<A>(weak obj: A, _ onNext: @escaping (A) -> (Self.Element) -> Void) -> Observable<Self.Element> where A : AnyObject {
        return self.do(onNext: { [weak obj](element) in
            guard let obj = obj else {return}
            onNext(obj)(element)
        })
    }
}
