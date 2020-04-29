//
//  ConversationConvertible.swift
//  ChatApp
//
//  Created by Mireya Orta on 2/5/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatNetworkingFirestore
import ChatUI
import Foundation
import FirebaseFirestoreSwift

extension Conversation: ChatModel {}

extension Conversation: Decodable {
    private enum CodingKeys: CodingKey {
        case id, lastMessage, messages, members, seen
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let id = try values.decode(DocumentID<String>.self, forKey: .id).wrappedValue else {
            throw ChatError.incompleteDocument
        }
        
        let lastMessage = try values.decodeIfPresent(Message.self, forKey: .lastMessage)
        let memberIds = try values.decode([EntityIdentifier].self, forKey: .members)
        let seen = try values.decodeIfPresent([String: SeenItem].self, forKey: .seen)?.reduce(into: Seen(), { (result, item) in
            let (key, value) = item
            result[key] = (messageId: value.messageId, seenAt: value.timestamp)
        }) ?? [:]
        
        self.init(id: id, lastMessage: lastMessage, memberIds: memberIds, seen: seen)
    }
}
