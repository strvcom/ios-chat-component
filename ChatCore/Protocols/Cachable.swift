//
//  Cachable.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/5/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Protocol required for object which tends to be cached
public protocol Cachable {
    init(from data: Data)
    func toData() -> Data
}

public extension Cachable where Self: Decodable {
    init(from data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

public extension Cachable where Self: Encodable {
    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

public struct Test: Codable, MessageSpecifying {
    let name: String
}
