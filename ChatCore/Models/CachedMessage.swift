//
//  Message.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/6/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Structure wrapping message specification and also allows to cache data
struct CachedMessage<T: MessageSpecifying & Cachable>: Codable, Equatable {
    var content: T
    var conversationId: ObjectIdentifier

    static func == (lhs: CachedMessage<T>, rhs: CachedMessage<T>) -> Bool {
        lhs.content == rhs.content && lhs.conversationId == rhs.conversationId
    }
}
