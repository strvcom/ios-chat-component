//
//  ChatFirestore+SendMessage.swift
//  ChatNetworkingFirestore
//
//  Created by Jan on 03/11/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import FirebaseFirestore

public extension ChatFirestore {
    func send(message: MessageSpecificationFirestore, to conversation: EntityIdentifier, completion: @escaping (Result<EntityIdentifier, ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.prepareMessageData(message: message) { result in
                guard case var .success(data) = result else {
                    if case let .failure(error) = result {
                        print("Error while preparing message data \(error)")
                        completion(.failure(error))
                    }
                    return
                }

                let referenceConversation = self.database
                    .collection(self.constants.conversations.path)
                    .document(conversation)


                let referenceMessage = referenceConversation
                    .collection(self.constants.messages.path)
                    .document()

                self.database.runTransaction({ (transaction, _) -> Any? in

                    transaction.setData(data, forDocument: referenceMessage)
                    
                    if self.config.updateLastMessage {
                        data[Constants.identifierAttributeName] = referenceMessage.documentID
                        transaction.updateData([self.constants.conversations.lastMessageAttributeName: data], forDocument: referenceConversation)
                    }

                    return nil
                }, completion: { (_, error) in
                    if let error = error {
                        completion(.failure(.networking(error: error)))
                    } else {
                        completion(.success(referenceMessage.documentID))
                    }
                })
            }
        }
    }

    private func prepareMessageData(message: MessageSpecificationFirestore, completion: @escaping (Result<[String: Any], ChatError>) -> Void) {
        let json = message.json
        
        uploadMedia(for: json) { [weak self] result in
            guard let self = self, case let .success(json) = result else {
                if case let .failure(error) = result {
                    completion(.failure(error))
                }

                return
            }

            var newJSON: [String: Any] = json
            newJSON[self.constants.messages.userIdAttributeName] = self.currentUserId
            newJSON[self.constants.messages.sentAtAttributeName] = Timestamp()
            completion(.success(newJSON))
        }
    }
    
    private func uploadMedia(for json: ChatJSON, completion: @escaping (Result<ChatJSON, ChatError>) -> Void) {
        var normalizedJSON: ChatJSON = [:]
        var resultError: ChatError?
        
        let dispatchGroup = DispatchGroup()
        
        for (key, value) in json {
            switch value {
            case let value as MediaContent:
                dispatchGroup.enter()
                
                mediaUploader.upload(content: value, on: self.networkingQueue) { result in
                    switch result {
                    case .success(let url):
                        normalizedJSON[key] = url.absoluteString
                    case .failure(let error):
                        resultError = error
                    }
                    
                    dispatchGroup.leave()
                }
            case let value as ChatJSON:
                dispatchGroup.enter()
                
                uploadMedia(for: value) { result in
                    switch result {
                    case .success(let json):
                        normalizedJSON[key] = json
                    case .failure(let error):
                        resultError = error
                    }
                    
                    dispatchGroup.leave()
                }
            default:
                normalizedJSON[key] = value
            }
        }
        
        dispatchGroup.notify(queue: self.networkingQueue) {
            if let error = resultError {
                completion(.failure(error))
            } else {
                completion(.success(normalizedJSON))
            }
        }
    }

}
