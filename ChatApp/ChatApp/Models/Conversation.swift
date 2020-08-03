//
//  Conversation.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseFirestoreSwift

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

extension Conversation: ChatModel {}

// TODO: Try to figure out how to infer this
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
