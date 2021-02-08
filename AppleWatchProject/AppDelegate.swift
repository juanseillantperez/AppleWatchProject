//
//  AppDelegate.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07//2020.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Current.appleWatch().initialize()
        return true
    }

    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print("didFailToContinueUserActivityWithType \(userActivityType) failure: \(error)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Current.appleWatch().applicationWillTerminate()
    }
}
