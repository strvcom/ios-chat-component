//
//  ChatFirestore+DeleteMessage.swift
//  ChatNetworkingFirestore
//
//  Created by Jan on 03/11/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import FirebaseFirestore

// MARK: - Delete message
public extension ChatFirestore {
    func delete(message: MessageFirestore, from conversation: EntityIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.lastMessage(after: message.id, from: conversation) { result in

                guard case let .success(newLastMessage) = result else {
                    if case let .failure(error) = result {
                        print("Error while loading last message \(error)")
                        completion(.failure(error))
                    }

                    return
                }

                let referenceConversation = self.database
                    .collection(self.constants.conversations.path)
                    .document(conversation)

                let referenceMessage = referenceConversation
                    .collection(self.constants.messages.path)
                    .document(message.id)

                self.database.runTransaction({ (transaction, _) -> Any? in

                    transaction.deleteDocument(referenceMessage)
                    // TODO: Handle do not update last message
                    transaction.updateData([self.constants.conversations.lastMessageAttributeName: newLastMessage ?? FieldValue.delete], forDocument: referenceConversation)

                    return nil
                }, completion: { (_, error) in
                    if let error = error {
                        completion(.failure(.networking(error: error)))
                    } else {
                        completion(.success(()))
                    }
                })
            }
        }
    }

    private func lastMessage(after messageId: EntityIdentifier, from conversation: EntityIdentifier, completion: @escaping (Result<[String: Any]?, ChatError>) -> Void) {
        
        let lastMessageQuery = messagesQuery(conversation: conversation, numberOfMessages: 2)
        lastMessageQuery.getDocuments { (snapshot, error) in
            if let error = error {
                return completion(.failure(.networking(error: error)))
            } else {
                // conversation can be empty
                let newLastMessage = snapshot?.documents.last(where: { $0.documentID != messageId })
                completion(.success(newLastMessage?.data()))
            }
        }
    }
}
