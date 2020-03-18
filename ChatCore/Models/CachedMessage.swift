//
//  Message.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/6/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - State of cached message
enum CachedMessageState: String, Codable {
    case stored
    case sending
}

// MARK: - Structure wrapping message specification and also allows to cache data
struct CachedMessage<T: MessageSpecifying & Cachable>: Codable {
    let content: T
    let conversationId: ObjectIdentifier
    private let id: ObjectIdentifier = UUID().uuidString
    private(set) var state: CachedMessageState

    init(content: T, conversationId: ObjectIdentifier, state: CachedMessageState) {
        self.content = content
        self.conversationId = conversationId
        self.state = state
    }

    // change state of cached message
    mutating func changeState(state: CachedMessageState) {
        self.state = state
    }
}

// MARK: - Equatable
extension CachedMessage: Equatable {
    static func == (lhs: CachedMessage<T>, rhs: CachedMessage<T>) -> Bool {
        lhs.id == rhs.id
    }
}
