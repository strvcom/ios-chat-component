//
//  MessageRepresenting+MessageType.swift
//  ChatUI
//
//  Created by Jan on 25/06/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import MessageKit

public extension ContentfulMessageRepresenting {
    var messageId: String {
        id
    }
    
    var sender: SenderType {
        // TODO: Sender name
        Sender(senderId: self.userId, displayName: "")
    }
    
    var sentDate: Date {
        sentAt
    }
    
    var kind: MessageKind {
        content.kind
    }
    
    var messageType: MessageType {
        Message(sender: sender, messageId: id, sentDate: sentAt, kind: kind)
    }
}
