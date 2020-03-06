//
//  IdentifiableClosure.swift
//  ChatApp
//
//  Created by Tomas Cejka on 2/26/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Helper structure, which allows identify closure by generated id

struct IdentifiableClosure<T, U>: Equatable, Hashable, ObjectIdentifiable {
    let id: ObjectIdentifier
    private(set) var closure: Closure<T, U>

    init(_ closure: @escaping Closure<T, U>) {
        id = UUID().uuidString
        self.closure = closure
    }

    static func == (lhs: IdentifiableClosure, rhs: IdentifiableClosure) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
