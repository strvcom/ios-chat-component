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
        partner?.name ?? .conversation
    }
    
    var partner: User? {
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
    
    var compatibility: CGFloat {
        CGFloat(partner?.compatibility ?? 0)
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
