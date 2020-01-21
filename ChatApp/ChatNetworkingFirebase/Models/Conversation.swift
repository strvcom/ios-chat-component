//
//  Conversation.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct ConversationFirestore: ConversationRepresenting, Decodable {
    public typealias Seen = [String: (messageId: ChatIdentifier, seenAt: Date)]

    public let id: ChatIdentifier
    public let lastMessage: MessageFirestore?
    public let members: [UserFirestore]
    public let messages: [MessageFirestore] = []
    public let seen: Seen

    private enum CodingKeys: CodingKey {
        case id, lastMessage, messages, members, seenAt
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let id = try values.decode(DocumentID<String>.self, forKey: .id).wrappedValue else {
            throw ChatError.internal(message: "Missing documentID")
        }
        
        self.id = id
        self.lastMessage = try values.decodeIfPresent(Message.self, forKey: .lastMessage)
        self.members = try values.decode([String: UserFirestore].self, forKey: .members).compactMap { $0.value.reinit(withId: $0.key) }
        self.seen = try values.decodeIfPresent([String: SeenItem].self, forKey: .seenAt)?.reduce(into: Seen(), { (result, item) in
            let (key, value) = item
            result[key] = (messageId: value.messageId, seenAt: value.timestamp)
        }) ?? [:]
    }
}

