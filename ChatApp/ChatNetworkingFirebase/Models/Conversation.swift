//
//  Conversation.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public struct ConversationFirestore: ConversationRepresenting, Decodable {
    public typealias Seen = [String: (messageId: ChatIdentifier, seenAt: Date)]

    public let id: ChatIdentifier
    public let lastMessage: MessageFirestore?
    public let members: [UserFirestore]
    public let messages: [MessageFirestore]
    public let seen: Seen

    private enum CodingKeys: CodingKey {
        case id
        case lastMessage
    }

    // TODO: Incomplete init
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(ChatIdentifier.self, forKey: .id)
        self.lastMessage = try values.decode(Message.self, forKey: .lastMessage)

        // DUMMY DATA
        self.members = []
        self.messages = []
        self.seen = [:]
    }
}

