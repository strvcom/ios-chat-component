//
//  Message.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/6/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Structure wrapping message specification and also allows to cache data
struct CachedMessage<T: MessageSpecifying & Cachable>: Codable {

    let content: T
    let conversationId: ObjectIdentifier
    let id: ObjectIdentifier
    private(set) var state: CachedMessageState

    init(content: T, conversationId: ObjectIdentifier, state: CachedMessageState) {
        self.id = UUID().uuidString
        self.content = content
        self.conversationId = conversationId
        self.state = state
        id = UUID().uuidString
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
