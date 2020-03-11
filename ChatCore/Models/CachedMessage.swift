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
    var content: T
    var conversationId: ObjectIdentifier
    var id: ObjectIdentifier

    init(content: T, conversationId: ObjectIdentifier) {
        id = UUID().uuidString
        self.content = content
        self.conversationId = conversationId
    }
}

// MARK: - Equatable
extension CachedMessage: Equatable {
    static func == (lhs: CachedMessage<T>, rhs: CachedMessage<T>) -> Bool {
        lhs.id == rhs.id
    }
}
