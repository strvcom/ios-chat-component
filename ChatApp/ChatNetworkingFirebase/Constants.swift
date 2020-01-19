//
//  Constants.swift
//  ChatNetworkingFirebase
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

struct Constants {
    static let defaultIdAttributeName = "id"
    static let conversationsPath = "conversations"
    static let messagesPath = "messages"
    static let usersPath = "users"
    
    struct Message {
        static let senderIdAttributeName = "userId"
        static let messageTypeAttributeName = "type"
        static let dataAttributeName = "data"
        static let sentAtAttributeName = "sentAt"
    }
}
