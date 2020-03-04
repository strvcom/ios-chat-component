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

extension Conversation: ChatNetworkingConvertible {
    public typealias NetworkingModel = ConversationFirestore
}

extension ConversationFirestore: ChatUIConvertible {

    public var uiModel: Conversation {
        let uiMembers = self.members.compactMap { $0.uiModel }
        let uiMessages = self.messages.compactMap { $0.uiModel }
        return Conversation(id: self.id, lastMessage: self.lastMessage?.uiModel, members: uiMembers, messages: uiMessages, seen: self.seen)
    }

    public init(uiModel: Conversation) {
        let newMessages = uiModel.messages.compactMap { MessageFirestore(uiModel: $0) }
        var newLastMessages: MessageFirestore?
        if let lastMessage = uiModel.lastMessage {
            newLastMessages = MessageFirestore(uiModel: lastMessage)
        }

        let newMembers = uiModel.members.compactMap { UserFirestore(uiModel: $0) }
        let newMembersIds = uiModel.members.compactMap { "\($0.id)" }
        self.init(id: uiModel.id, lastMessage: newLastMessages, members: newMembers, messages: newMessages, seen: [:], memberIds: newMembersIds)
    }
}
