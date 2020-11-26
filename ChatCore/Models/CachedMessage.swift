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
    let conversationId: EntityIdentifier
    let id: EntityIdentifier
    let userId: EntityIdentifier
    private(set) var state: CachedMessageState

    init(id: EntityIdentifier, content: T, conversationId: EntityIdentifier, userId: EntityIdentifier, state: CachedMessageState) {
        self.id = id
        self.content = content
        self.conversationId = conversationId
        self.state = state
        self.userId = userId
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
