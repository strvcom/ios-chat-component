//
//  ChatFirestoreConstants.swift
//  ChatNetworkingFirebase
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public struct ChatFirestoreConstants {
    public var conversations = Conversations()
    public var messages = Messages()
    public var users = Users()
    
    public init() {}
}

// MARK: Enclosed objects definitions
public extension ChatFirestoreConstants {
    struct Messages {
        public var path = "messages"
        
        public var userIdAttributeName = "userId"
        public var sentAtAttributeName = "sentAt"
    }
    
    struct Conversations {
        public var path = "conversations"
        
        public var seenAttribute = SeenMessages()
        public var lastMessageAttributeName = "lastMessage"
        public var membersAttributeName = "members"
        public var typingUsersAttributeName = "typingUsers"
    }
    
    struct SeenMessages {
        public var name = "seen"

        public var messageIdAttributeName = "messageId"
        public var timestampAttributeName = "timestamp"
    }
    
    struct Users {
        public var path = "users"
    }
}
