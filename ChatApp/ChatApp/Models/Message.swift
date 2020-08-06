//
//  MessageKitType.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatUI
import Foundation
import MessageKit
import FirebaseFirestore

struct Message: MessageWithContent, MessageConvertible, MessageStateReflecting {
    let id: EntityIdentifier
    let userId: EntityIdentifier
    let sentAt: Date
    let content: MessageContent
    var state: MessageState = .sent

    init(id: EntityIdentifier, userId: EntityIdentifier, sentAt: Date, messageSpecification: MessageContent, state: MessageState = .sending) {
        self.id = id
        self.userId = userId
        self.sentAt = sentAt
        self.content = messageSpecification
        self.state = state
    }
}

extension Message: ChatModel {}

extension Message: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case content = "data"
        case sentAt
    }
}
