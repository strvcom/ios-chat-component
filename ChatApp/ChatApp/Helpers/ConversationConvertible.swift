//
//  ConversationConvertible.swift
//  ChatApp
//
//  Created by Mireya Orta on 2/5/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatNetworkFirebase
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
        let nwMessages = uiModel.messages.compactMap { MessageFirestore(uiModel: $0) }
        var nwLasMessages: MessageFirestore? = nil
        if let lasMessage = uiModel.lastMessage {
            nwLasMessages = MessageFirestore(uiModel: lasMessage)
        }

        let nwMembers = uiModel.members.compactMap { UserFirestore(uiModel: $0) }
        let nwMembersIds = uiModel.members.compactMap { "\($0.id)" }
        self.init(id: uiModel.id, lastMessage: nwLasMessages, members: nwMembers, messages: nwMessages, seen: [:], memberIds: nwMembersIds)
    }
}
