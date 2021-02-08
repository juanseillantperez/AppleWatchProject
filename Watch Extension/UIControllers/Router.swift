//
//  Rputer.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
import WatchKit

class Router {
    static func displayAlert(action: WatchAction,
                             alertType: AlertType = .error,
                             from controller: WKInterfaceController? = nil,
                             dismissAction dismiss: WKAlertAction? = nil) {
        guard let controller = controller else {return}

        let dismissAction: WKAlertAction = dismiss ?? .ok {
            Router.openWelcomeScreen()
        }

        controller.presentAlert(withTitle: alertType.displayString,
                                message: action.displayString,
                                preferredStyle: .alert,
                                actions: [dismissAction])
    }

    static func openWaitingForWorkoutScreen() {
        dispatchReloadRootPageControllers([WaitingForWorkoutInterfaceController.identifier])
    }

    static func openWorkoutScreen() {
        dispatchReloadRootPageControllers([WorkoutSessionInterfaceController.identifier,
                                           "Now Playing"],
                                          pageIndex: 0)
    }

    static func openWorkoutSummaryScreen(with summaryInfo: WorkoutSummary) {
        dispatchReloadRootPageControllers([WorkoutSummaryController.identifier], contexts: [summaryInfo])
    }

    static func openWelcomeScreen() {
        dispatchReloadRootPageControllers([InitialInterfaceController.identifier])
    }
    

}

//MARK: - Helpers

enum WatchAction {
    case startWorkout
    case endWorkout
    case workOutError
    case initializeHealthKit
    case missingShareAuthorization
    case readPermission

    var displayString : String {
        switch self {
        case .startWorkout : return "There was an error trying to start your workout."
        case .endWorkout :  return "There was an error trying to finish your workout."
        case .workOutError : return "There was an error during your workout."
        case .initializeHealthKit : return "There was an error trying to initialize HealthKit."
        case .missingShareAuthorization : return sharePermissionsText
        case .readPermission : return readPermissionsText
        }
    }
}

private let readPermissionsText = "24GO needs permissions to read your heart rate and calories. Please go to 'Settings -> Health -> Apps -> 24GO'"
private let sharePermissionsText = "24GO needs permissions to share your workout. Please go to 'Settings -> Health -> Apps -> 24GO'"

//MARK: -

enum AlertType {
    case info
    case error

    var displayString : String {
        switch self {
        case .info : return "Information"
        case .error :  return "Error"
        }
    }
}

//MARK: -

private extension WKInterfaceController {
    static var identifier : String {
        "\(Self.self)"
    }

    static func reloadAsRoot(contexts: [Any]? = nil,
                           orientation: WKPageOrientation = .horizontal,
                           pageIndex: Int = 0) {

        dispatchReloadRootPageControllers([Self.identifier], contexts: contexts, orientation: orientation, pageIndex: pageIndex)
    }
}

private func dispatchReloadRootPageControllers(_ names:[String],
                contexts:[Any]? = nil,
                orientation : WKPageOrientation = .horizontal,
                pageIndex: Int = 0 ) {
    DispatchQueue.main.async() {
        WKInterfaceController.reloadRootPageControllers(withNames: names, contexts: contexts, orientation: orientation, pageIndex: pageIndex)
    }
}
