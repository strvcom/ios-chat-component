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
                .collection(self.constants.typingUsers.path)
                .document(userId)

            isTyping ? self.setTypingUser(typingUserReference: document) : self.removeTypingUser(typingUserReference: document)
        }
    }

    private func setTypingUser(typingUserReference: DocumentReference) {
        typingUserReference.setData([:]) { error in
            if let err = error {
                print("Error updating user typing: \(err)")
            } else {
                print("Typing user successfully set")
            }
        }
    }

    private func removeTypingUser(typingUserReference: DocumentReference) {
        typingUserReference.delete { error in
            if let err = error {
                print("Error deleting user typing: \(err)")
            } else {
                print("Typing user successfully removed")
            }
        }
    }

    public func listenToTypingUsers(in conversation: EntityIdentifier, completion: @escaping (Result<[EntityIdentifier], ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let query = self.database
                .collection(self.constants.conversations.path)
                .document(conversation)
                .collection(self.constants.typingUsers.path)

            let listener = Listener.typingUsers(conversationId: conversation)

            self.listenToCollection(query: query, listener: listener, completion: completion)
        }
    }
}
