//
//  DispatchQueue + afterSeconds.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
public extension DispatchQueue {
    func asyncAfter(seconds:TimeInterval, execute action:@escaping () -> Void) {

        let dispatchTime : DispatchTime = DispatchTime.now() + seconds
        self.asyncAfter(deadline:  dispatchTime, execute:action)
    }
}
