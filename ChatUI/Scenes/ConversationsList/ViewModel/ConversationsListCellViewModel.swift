//
//  ConversationsListCellViewModel.swift
//  ChatApp
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

struct ConversationsListCellViewModel {
    
    enum MessagePreview {
        case newConversation
        case message(String)
        case other
    }
    
    private let conversation: Conversation
    private let currentUser: User
    
    var title: String {
        
        // Filter out current user's name
        let title = conversation.members
            .filter { $0.id != currentUser.id }
            .compactMap { $0.name }
            .joined(separator: ",")
        
        return title.isEmpty ? "Conversation" : title
    }
    
    var messagePreview: MessagePreview {
        if case let .text(message) = conversation.lastMessage?.kind {
            return message.isEmpty ? .newConversation : .message(message)
        }
        
        return .other
    }
    
    var avatarUrl: URL? {
        return conversation.members
            .first { $0.id != currentUser.id }?
            .imageUrl
    }
    
    var compatibility: CGFloat {
        CGFloat(conversation.compatibility)
    }
    
    // TODO: How is this color determined?
    var circleColor: UIColor {
        .conversationsCircleDefault
    }
    
    init(conversation: Conversation, currentUser: User) {
        self.conversation = conversation
        self.currentUser = currentUser
    }
}
