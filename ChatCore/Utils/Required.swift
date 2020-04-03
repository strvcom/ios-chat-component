//
//  Required.swift
//  ChatCore
//
//  Created by Tomas Cejka on 4/2/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Property wrapper to validate value has been set
@propertyWrapper
public struct Required<T> {
    public var wrappedValue: T?
    public var projectedValue: T {
        guard let value = wrappedValue else {
            fatalError("Unexpected error, \(T.self) is nil")
        }
        return value
    }

    public init() {
        self.wrappedValue = nil
    }
}
