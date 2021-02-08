//
//  Environment.swift
//  AppleWatch WatchKit Extension
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation

public var Current : Environment = .production

extension Environment {
    public static var production : Environment = {
        return Environment()
    }()
}

public struct Environment {

    public var toolbox : Toolbox = Toolbox()

}
