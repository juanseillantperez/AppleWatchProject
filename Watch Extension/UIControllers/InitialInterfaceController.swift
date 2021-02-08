//
//  InterfaceController.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import WatchKit
import Foundation


class InitialInterfaceController: WKInterfaceController {
    private var healthKit : HealthKit = Current.toolbox.healthKit()
    private var phoneApp : PhoneApp = Current.toolbox.phoneApp()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.phoneApp.sendLaunchMessages()
        if self.healthKit.hasAuthorizationToShare() {
            Router.openWaitingForWorkoutScreen()
        }
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    @IBAction func requestPermissions() {
        self.healthKit.initialize { [weak self](result) in
            guard let self = self else {return}

            if !result.isSuccess {
                Router.displayAlert(action: .initializeHealthKit)
            } else if self.healthKit.hasAuthorizationToShare() {
                Router.openWaitingForWorkoutScreen()
            } else {
                Router.displayAlert(action: .missingShareAuthorization, alertType: .error, from: self, dismissAction: .ok())
            }

        }
    }
    
}
extension WKAlertAction {
    static func ok( handler: WKAlertActionHandler? = nil) -> WKAlertAction {
        WKAlertAction(title: "Ok", style: .cancel, handler: handler ?? {})
    }
}
