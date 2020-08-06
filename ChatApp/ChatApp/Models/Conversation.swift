//
//  Conversation.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseFirestore

struct Conversation: ConversationRepresenting, MembersStoring {
    let id: EntityIdentifier
    let lastMessage: Message?
    let memberIds: [EntityIdentifier]
    private(set) var members: [User] = []
    let seen: [String: SeenItem]

    mutating func setMembers(_ members: [User]) {
        self.members = members
    }
}

extension Conversation: ChatModel {}

extension Conversation: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case lastMessage
        case memberIds = "members"
        case seen
    }
}

extension SeenItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case messageId
        case seenAt = "timestamp"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let messageId = try values.decode(EntityIdentifier.self, forKey: .messageId)
        let timestamp = try values.decode(Date.self, forKey: .seenAt)

        self = .init(messageId: messageId, seenAt: timestamp)
    }
}
