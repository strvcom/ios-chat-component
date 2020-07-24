//
//  ConversationsListCellViewModel.swift
//  ChatApp
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

struct ConversationsListCellViewModel<Conversation: ConversationRepresenting> where Conversation.Message: MessageWithContent {
    
    enum MessagePreview {
        case newConversation
        case message(String)
        case other
    }
    
    private let conversation: Conversation
    private let currentUser: Conversation.User
    
    var title: String {
        partner?.name ?? .conversation
    }
    
    var partner: Conversation.User? {
        conversation
            .members
            .first { $0.id != currentUser.id }
    }
    
    var messagePreview: MessagePreview {
        guard let lastMessage = conversation.lastMessage else {
            return .newConversation
        }
        
        switch lastMessage.kind {
        case let .text(message):
            return .message(message)
        default:
            return .other
        }
    }
    
    var avatarUrl: URL? {
        partner?.imageUrl
    }
    
    init(conversation: Conversation, currentUser: Conversation.User) {
        self.conversation = conversation
        self.currentUser = currentUser
    }
}
