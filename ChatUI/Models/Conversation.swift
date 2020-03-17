//
//  Conversation.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public struct Conversation: ConversationRepresenting {
    public typealias Seen = [String: (messageId: ObjectIdentifier, seenAt: Date)]

    public let id: ObjectIdentifier
    public let lastMessage: MessageKitType?
    public let members: [User]
    public let messages: [MessageKitType]
    public let seen: Seen
    public let compatibility: Float

    public init(id: ObjectIdentifier, lastMessage: MessageKitType?, members: [User], messages: [MessageKitType], seen: Seen, compatibility: Float) {
        self.id = id
        self.lastMessage = lastMessage
        self.members = members
        self.messages = messages
        self.seen = seen
        self.compatibility = compatibility
    }
}
