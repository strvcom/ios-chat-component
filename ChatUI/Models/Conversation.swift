//
//  Conversation.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public struct Conversation: ConversationRepresenting, MembersStoring {
    public typealias Seen = [String: (messageId: EntityIdentifier, seenAt: Date)]

    public let id: EntityIdentifier
    public let lastMessage: Message?
    public let memberIds: [EntityIdentifier]
    public private(set) var members: [User]
    public let seen: Seen

    public init(id: EntityIdentifier, lastMessage: Message?, memberIds: [EntityIdentifier], seen: Seen) {
        self.id = id
        self.lastMessage = lastMessage
        self.memberIds = memberIds
        self.members = []
        self.seen = seen
    }
    
    public init(id: EntityIdentifier, lastMessage: Message?, members: [User], seen: Seen) {
        self.id = id
        self.lastMessage = lastMessage
        self.memberIds = members.map({ $0.id })
        self.members = members
        self.seen = seen
    }

    public mutating func setMembers(_ members: [User]) {
        self.members = members
    }
}
