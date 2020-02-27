//
//  Conversationable.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ConversationRepresenting: ObjectIdentifiable {
    associatedtype Message: MessageRepresenting
    associatedtype User: UserRepresenting
    
    var lastMessage: Message? { get }
    var members: [User] { get }
    var messages: [Message] { get }
    var seen: [String: (messageId: ObjectIdentifier, seenAt: Date)] { get }
}
