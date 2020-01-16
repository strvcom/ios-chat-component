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
    public typealias Seen = [String: (messageId: ChatIdentifier, seenAt: Date)]

    public let id: ChatIdentifier
    public let lastMessage: MessageKitType?
    public let members: [User]
    public let messages: [MessageKitType]
    public let seen: Seen

    public init(id: ChatIdentifier, lastMessage: MessageKitType?, members: [User], messages: [MessageKitType], seen: Seen) {
        self.id = id
        self.lastMessage = lastMessage
        self.members = members
        self.messages = messages
        self.seen = seen
    }
}
