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
    private var value: T?
    public var projectedValue: Bool {
        value != nil
    }
    public var wrappedValue: T {
        get {
            guard let value = value else {
                fatalError("Unexpected error, \(T.self) is nil")
            }
            return value
        }
        set {
            value = newValue
        }
    }
    public init() {
        self.value = nil
    }
}
