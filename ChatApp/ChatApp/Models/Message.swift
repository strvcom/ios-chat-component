//
//  MessageKitType.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import ChatUI

struct Message: ContentfulMessageRepresenting {
    let id: EntityIdentifier
    let userId: EntityIdentifier
    let sentAt: Date
    let type: String
    let content: MessageContent
    var state: MessageState = .sent

    init(id: EntityIdentifier, userId: EntityIdentifier, sentAt: Date, messageSpecification: MessageContent, state: MessageState = .sending) {
        self.id = id
        self.userId = userId
        self.sentAt = sentAt
        self.type = messageSpecification.identifier
        self.content = messageSpecification
        self.state = state
    }
}

extension Message: ChatModel {}

extension Message: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case sentAt
        case type
        case content = "data"
    }
}
