//
//  MessageRepresenting+MessageType.swift
//  ChatUI
//
//  Created by Jan on 25/06/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import MessageKit

struct Message: MessageType {
    let sender: SenderType
    let messageId: String
    let sentDate: Date
    let kind: MessageKind
}

extension MessageWithContent {
    var messageType: MessageType {
        // TODO: Add display name
        Message(sender: Sender(senderId: userId, displayName: ""), messageId: id, sentDate: sentAt, kind: kind)
    }
}
