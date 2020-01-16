//
//  FirebaseConverter.swift
//  ChatApp
//
//  Created by Mireya Orta on 1/16/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatNetworkFirebase
import ChatUI
import Foundation

public class FirebaseConverter: ChatUIModelConverting {
    public typealias Networking = ChatNetworkFirebase
    public typealias MUI = MessageKitType
    public typealias CUI = Conversation
    public typealias MSUI = MessageSpecification

    public func convert(messageSpecification: MessageSpecification) -> MessageSpecificationFirestore {
        // FIXME: Dummy implementation
        return MessageSpecificationFirestore.text(message: "Bla")
    }

    public func convert(message: MessageFirestore?) -> MessageKitType? {
        guard let message = message else { return nil }
        // FIXME: Dummy implementation
        var messageContect: MessageContent
        switch message.content {
        case .text(let text):
            messageContect = .text(message: text)
        default:
            //update with image
            messageContect = .text(message: "BLAAA")
        }
        return MessageKitType(id: message.id, userId: message.userId, sentAt: message.sentAt, content: messageContect)
    }

    public func convert(conversation: ConversationFirestore) -> Conversation {
        // FIXME: Dummy implementation

        return Conversation(id: conversation.id, lastMessage: convert(message: conversation.lastMessage), members: [], messages: conversation.messages.compactMap{ convert(message: $0)}, seen: conversation.seen)
    }
}
