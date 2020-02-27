//
//  IdentifiableClosure.swift
//  ChatApp
//
//  Created by Tomas Cejka on 2/26/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Helper structure, which allows identify closure by generated id
public struct IdentifiableClosure<T, U>: Equatable, Identifiable {
    public let id: ChatIdentifier
    public let closure: Closure<T, U>

    public init(_ closure: @escaping Closure<T, U>) {
        id = UUID().uuidString
        self.closure = closure
    }

    public static func == (lhs: IdentifiableClosure, rhs: IdentifiableClosure) -> Bool {
        return lhs.id == rhs.id
    }
}
