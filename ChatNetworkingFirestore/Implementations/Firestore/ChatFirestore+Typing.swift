//
//  ChatFirestore+Typing.swift
//  ChatNetworkingFirestore
//
//  Created by Jan on 02/11/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import FirebaseFirestore

extension ChatFirestore: ChatNetworkingWithTypingUsers {
    public func setUserTyping(userId: EntityIdentifier, isTyping: Bool, in conversation: EntityIdentifier) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let document = self.database
                .collection(self.constants.conversations.path)
                .document(conversation)
            
            self.database.runTransaction({ (transaction, _) -> Any? in
                guard
                    let conversation = try? transaction.getDocument(document),
                    let conversationData = conversation.data(),
                    var typingUsers = conversationData[self.constants.conversations.typingUsersAttributeName] as? [EntityIdentifier: Bool]
                else {
                    return nil
                }
                
                typingUsers[userId] = isTyping
                
                transaction.updateData([
                    self.constants.conversations.typingUsersAttributeName: typingUsers
                ], forDocument: conversation.reference)
                
                return nil
            }, completion: { (_, _) in })
        }
    }
}
