//
//  Result + Extensions.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
extension Result {
    var isSuccess : Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
}

extension Result where Success == Void {
    static var success : Result {
        return .success(())
    }
}
