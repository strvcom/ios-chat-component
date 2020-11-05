//
//  ChatFirestore+UpdateSeenMessage.swift
//  ChatNetworkingFirestore
//
//  Created by Jan on 03/11/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import FirebaseFirestore

public extension ChatFirestore {
    func updateSeenMessage(_ message: EntityIdentifier, in conversation: EntityIdentifier) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            let reference = self.database
                .collection(self.constants.conversations.path)
                .document(conversation)

            self.database.runTransaction({ (transaction, errorPointer) -> Any? in
                var currentConversation: ConversationFirestore?
                do {
                    let conversationSnapshot = try transaction.getDocument(reference)
                    currentConversation = try conversationSnapshot.decode(to: ConversationFirestore.self, with: self.decoder)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }

                guard let seenItems = currentConversation?.seen else {
                    return nil
                }

                var json: [String: Any] = seenItems.mapValues({
                    [self.constants.conversations.seenAttribute.messageIdAttributeName: $0.messageId,
                     self.constants.conversations.seenAttribute.timestampAttributeName: $0.seenAt]
                })
                
                json[self.currentUserId] = [
                    self.constants.conversations.seenAttribute.messageIdAttributeName: message,
                    self.constants.conversations.seenAttribute.timestampAttributeName: Timestamp()
                ]

                transaction.updateData([self.constants.conversations.seenAttribute.name: json], forDocument: reference)

                return nil
            }, completion: { (_, error) in
                if let err = error {
                    print("Error updating conversation last seen message: \(err)")
                } else {
                    print("Conversation last seen message successfully updated")
                }
            })
        }
    }
}
