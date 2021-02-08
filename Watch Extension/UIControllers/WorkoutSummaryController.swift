//
//  WorkoutSummaryController.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import WatchKit
import Foundation
import HealthKit

class WorkoutSummaryController: WKInterfaceController {
    @IBOutlet weak var totalCaloriesLabel: WKInterfaceLabel!
    @IBOutlet weak var actionBtn: WKInterfaceButton!
    @IBOutlet weak var avgHeartRateLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let summaryInfo = context as? WorkoutSummary {
            self.totalCaloriesLabel.setText("\(summaryInfo.caloriesBourned)")
            if let avgHR = summaryInfo.avgHeartRate {
                self.avgHeartRateLabel.setText("\(Int( round(avgHR) ))")
            } else {
                self.avgHeartRateLabel.setText("--")
            }
        }

    }
    @IBAction func actionCTA() {
        Router.openWelcomeScreen()
    }

}

struct WorkoutSummary {
    let caloriesBourned: Int
    let avgHeartRate: Double?
}
