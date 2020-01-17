//
//  ChatNetworkingFirebase.swift
//  ChatNetworkingFirebase
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import Firebase

public class ChatNetworkFirebase: ChatNetworkServicing {
    public struct Configuration {
        let configUrl: String
        
        public init(configUrl: String) {
            self.configUrl = configUrl
        }
    }
    
    let database: Firestore
    let decoder = JSONDecoder()

    private var listeners: [ChatListener: ListenerRegistration] = [:]

    required public init(config: Configuration) {
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }
        FirebaseApp.configure(options: options)
        
        self.database = Firestore.firestore()
    }
}

// MARK: Write data
public extension ChatNetworkFirebase {
    func send(message: MessageSpecificationFirestore, to conversation: ChatIdentifier, completion: @escaping (Result<MessageFirestore, ChatError>) -> Void) {

        message.toJSON { [weak self] json in
            guard let self = self else {
                return
            }
            
            let reference = self.database
                    .collection(Constants.conversationsPath)
                    .document(conversation)
                    .collection(Constants.messagesPath)

            var documentRef: DocumentReference?
            documentRef = reference.addDocument(data: json) { error in
                if let error = error {
                    completion(.failure(.networking(error: error)))
                } else if let ref = documentRef {
                    var messageJSON = json
                    messageJSON[Constants.defaultIdAttributeName] = ref.documentID
                    do {
                        let message: MessageFirestore = try self.decoder.decode(json: messageJSON)
                        completion(.success(message))
                    } catch {
                        completion(.failure(.serialization(error: error)))
                    }
                } else {
                    completion(.failure(.internal(message: "Unknown state while sending")))
                }
            }
        }
    }
}
 
// MARK: Listen to collections
public extension ChatNetworkFirebase {
    func listenToConversations(completion: @escaping (Result<[ConversationFirestore], ChatError>) -> Void) -> ChatListener {

        // FIXME: Make conversations path more generic
        let reference = database.collection(Constants.conversationsPath)
        return listenTo(reference: reference, completion: completion)
    }

    func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[MessageFirestore], ChatError>) -> Void) -> ChatListener {

        // FIXME: Make conversations path more generic
        let reference = database.collection(Constants.conversationsPath).document(id).collection(Constants.messagesPath)
        return listenTo(reference: reference, completion: completion)
    }
    
    func remove(listener: ChatListener) {
        listeners[listener]?.remove()
    }
}

// MARK: Private methods
private extension ChatNetworkFirebase {
    func listenTo<T: Decodable>(reference: CollectionReference, completion: @escaping (Result<[T], ChatError>) -> Void) -> ChatListener {
        let listener = reference.addSnapshotListener(includeMetadataChanges: false) { [weak self] (snapshot, error) in
            if let snapshot = snapshot, let self = self {
                do {
                    let list: [T] = try self.decoder.decode(snapshot: snapshot)
                    completion(.success(list))
                } catch {
                    completion(.failure(.serialization(error: error)))
                }
            } else if let error = error {
                completion(.failure(.networking(error: error)))
            } else {
                completion(.failure(.internal(message: "Unknown")))
            }
        }
        
        let identifier = ChatListener.generateIdentifier()
        
        listeners[identifier] = listener
        
        return identifier
    }
}
