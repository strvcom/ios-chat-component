//
//  Message.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/6/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Structure wrapping message specification and also allows to cache data
struct Message<T: MessageSpecifying & Cachable>: Codable {
    var content: T
    var conversationId: ObjectIdentifier
}
