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
    public typealias USRUI = User

    public func convert(user: UserFirestore) -> User {
        return User(id: user.id, name: user.name, imageUrl: user.imageUrl)
    }

    public func convert(messageSpecification: MessageSpecification) -> MessageSpecificationFirestore {
        switch messageSpecification {
        case .image(let image):
            return MessageSpecificationFirestore.image(image: image)
        case .text(let message):
            return MessageSpecificationFirestore.text(message: message)
        }
    }

    public func convert(message: MessageFirestore) -> MessageKitType {
        var messageContent: MessageContent
        switch message.content {
        case .text(let text):
            messageContent = .text(message: "\(text) (\(message.sentAt.description), from \(message.userId))")
        case .image(let imageUrl):
            messageContent = .image(imageUrl: imageUrl)
        }
        return MessageKitType(id: message.id, userId: message.userId, sentAt: message.sentAt, content: messageContent)
    }

    public func convert(conversation: ConversationFirestore) -> Conversation {
        var lastMessage: MessageKitType? = nil

        if let lastM = conversation.lastMessage {
            lastMessage = convert(message: lastM)
        }

        return Conversation(id: conversation.id, lastMessage: lastMessage,
                            members: conversation.members.compactMap{ convert(user: $0)},
                            messages: conversation.messages.compactMap{ convert(message: $0)},
                            seen: conversation.seen)
    }
}
