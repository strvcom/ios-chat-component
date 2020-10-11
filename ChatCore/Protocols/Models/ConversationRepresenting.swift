//
//  Conversationable.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Minimal representation of a conversation used by the core.
public protocol ConversationRepresenting: EntityIdentifiable {
    associatedtype Message: MessageRepresenting
    associatedtype User: UserRepresenting
    associatedtype SeenItem: SeenMessageRepresenting
    
    /// Copy of the last message in conversation
    var lastMessage: Message? { get }
    
    /// IDs of members participating in this conversation
    var memberIds: [EntityIdentifier] { get }
    
    /// Array of members participating in this conversation
    var members: [User] { get set }

    /// Dictionary of seen timestamps with userId as the key
    var seen: [String: SeenItem] { get }
}

// Default implementation of `memberIds` for conversations that stores directly member objects
public extension ConversationRepresenting {
    var memberIds: [EntityIdentifier] {
        members.map { $0.id }
    }
}
