//
//  Cachable.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/5/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Protocol required for object which needs to be cached
public protocol Cachable {
    init?(from data: Data)
    func toData() -> Data?
}

// MARK: - Defaul implementation for codable objects
public extension Cachable where Self: Decodable {
    init?(from data: Data) {
        do {
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            return nil
        }
    }
}

public extension Cachable where Self: Encodable {
    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
