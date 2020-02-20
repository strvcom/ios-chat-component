//
//  Constants.swift
//  ChatNetworkingFirebase
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

enum Constants {
    static let defaultIdAttributeName = "id"
    static let conversationsPath = "conversations"
    static let messagesPath = "messages"
    static let usersPath = "users"
    
    enum Message {
        static let senderIdAttributeName = "userId"
        static let messageTypeAttributeName = "type"
        static let dataAttributeName = "data"
        static let sentAtAttributeName = "sentAt"
        static let messageTypeText = "text"
        static let messageTypeImage = "image"
        static let dataAttributeNameText = "text"
        static let dataAttributeNameImage = "imageUrl"
        static let messageIdAttributeName = "messageId"
        static let timestampAttributeName = "timestamp"
        static let membersAttributeName = "members"
    }
    
    enum Conversation {
        static let seenAttributeName = "seen"
    }
}
