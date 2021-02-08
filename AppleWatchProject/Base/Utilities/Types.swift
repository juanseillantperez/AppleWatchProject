//
//  Types.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
public typealias Action = () -> Void
public typealias ErrorHandler = Handler<Error>
public typealias Generator<T> = () -> T
public typealias Handler<T> = (T) -> Void
