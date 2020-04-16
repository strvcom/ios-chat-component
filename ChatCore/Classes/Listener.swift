//
//  Listener.swift
//  ChatApp
//
//  Created by Daniel Pecher on 06/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// This enum is needed to identify identical listeners so that multiple requests with the same parameters are stored together and don't require extra network listeners.
public enum Listener: Hashable {
    case conversations(pageSize: Int)
    case messages(pageSize: Int, conversationId: EntityIdentifier)
    case typingUsers(conversationId: EntityIdentifier)
    case empty
}
