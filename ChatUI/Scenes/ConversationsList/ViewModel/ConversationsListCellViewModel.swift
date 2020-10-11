//
//  ConversationsListCellViewModel.swift
//  ChatApp
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

struct ConversationsListCellViewModel {
    enum MessagePreview {
        case newConversation
        case message(String)
        case other
    }
    
    let title: String
    let avatarURL: URL?
    let messagePreview: MessagePreview
    
    init<Conversation: ConversationRepresenting>(conversation: Conversation, currentUser: Conversation.User) where Conversation.Message: ContentfulMessageRepresenting {
        let partner = conversation
                        .members
                        .first { $0.id != currentUser.id }
        self.title = partner?.name ?? .conversation
        self.avatarURL = partner?.imageUrl
        
        guard let lastMessage = conversation.lastMessage else {
            self.messagePreview = .newConversation
            return
        }
        
        switch lastMessage.kind {
        case let .text(message):
            self.messagePreview = .message(message)
        case .photo:
            self.messagePreview = .message("Photo message")
        default:
            self.messagePreview = .other
        }
    }
}
