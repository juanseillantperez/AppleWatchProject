//
//  ObservableConvertibleType + Driver.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 05/01/2021.
//

import Foundation
import RxSwift
import RxCocoa

public extension ObservableConvertibleType {

    /**
     Converts observable sequence to `Driver` trait.

     - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
     - returns: Driver trait.
     */
    func asDriver(onErrorJustTransform transformation: @escaping (Error) -> Self.Element) -> RxCocoa.SharedSequence<RxCocoa.DriverSharingStrategy, Self.Element> {
        return self.asDriver(onErrorRecover: { .just(transformation($0))})
    }
}

public extension ObservableConvertibleType {

    func asDriverOrNever() -> Driver<Element> {
        return self.asDriver(onErrorRecover: { (error) -> SharedSequence<DriverSharingStrategy, Self.Element> in
            return .never()
        })
    }
}
