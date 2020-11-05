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
    public func setUserTyping(userId: EntityIdentifier, isTyping: Bool, in conversation: TypingStatusRepresenting) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let document = self.database
                .collection(self.constants.conversations.path)
                .document(conversation.id)
            
            document.setData([
                self.constants.conversations.typingUsersAttributeName: [
                    userId: isTyping
                ]
            ], merge: true)
        }
    }
}
