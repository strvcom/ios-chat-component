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

    private var listeners: [ChatListener: ListenerRegistration] = [:]
    private var usersListener: ChatListener?
    private var users: [UserFirestore] = []

    required public init(config: Configuration) {
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }
        FirebaseApp.configure(options: options)
        
        self.database = Firestore.firestore()
        
        // FIXME: Remove this temporary code when UI for conversation creating is ready
        NotificationCenter.default.addObserver(self, selector: #selector(createTestConversation), name: NSNotification.Name(rawValue: "TestConversation"), object: nil)
    }
    
    deinit {
        if let usersListener = usersListener {
            remove(listener: usersListener)
        }
    }
}

// FIXME: Remove this temporary method when UI for conversation creating is ready
private extension ChatNetworkFirebase {
    @objc func createTestConversation() {
        database
            .collection(Constants.usersPath)
            .getDocuments { [weak self] (querySnapshot, _) in
                guard
                    let self = self,
                    let querySnapshot = querySnapshot,
                    let users = try? querySnapshot.documents.compactMap({
                        try $0.data(as: UserFirestore.self)
                    }) else {
                        return
                }
                
                self.database
                    .collection(Constants.conversationsPath)
                    .addDocument(data: [
                        "members": users.map { $0.id }
                    ])
        }
    }
}

// MARK: - Load
public extension ChatNetworkFirebase {
    func load(completion: @escaping (Result<Void, ChatError>) -> Void) {
        usersListener = listenToUsers { [weak self] (result: Result<[UserFirestore], ChatError>) in
            switch result {
            case let .success(users):
                self?.users = users
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.networking(error: error)))
            }
        }
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

            let documentRef = reference.document()
            
            documentRef.setData(json) { error in
                if let error = error {
                    completion(.failure(.networking(error: error)))
                } else {
                    documentRef.getDocument { (documentSnapshot, error) in
                        if let error = error {
                            completion(.failure(.networking(error: error)))
                        } else if let message = try? documentSnapshot?.data(as: MessageFirestore.self) {
                            completion(.success(message))
                        } else {
                            completion(.failure(.unexpectedState))
                        }
                    }
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
        return listenTo(reference: reference, completion: { (result: Result<[ConversationFirestore], ChatError>) in
            
            guard case let .success(conversations) = result else {
                completion(result)
                return
            }
            
            // Set members from previously downloaded users
            completion(.success(conversations.map { conversation in
                var result = conversation
                result.members = self.users.filter { result.memberIds.contains($0.id) }
                return result
            }))
        })
    }

    func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[MessageFirestore], ChatError>) -> Void) -> ChatListener {

        // FIXME: Make conversations path more generic
        let reference = database
            .collection(Constants.conversationsPath)
            .document(id)
            .collection(Constants.messagesPath)
            .order(by: Constants.Message.sentAtAttributeName)
        return listenTo(reference: reference, completion: completion)
    }
    
    func listenToUsers(completion: @escaping (Result<[UserFirestore], ChatError>) -> Void) -> ChatListener {
        let reference = database.collection(Constants.usersPath)
        
        return listenTo(reference: reference, completion: completion)
    }
    
    func remove(listener: ChatListener) {
        listeners[listener]?.remove()
    }
}

// MARK: Private methods
private extension ChatNetworkFirebase {
    func listenTo<T: Decodable>(reference: Query, completion: @escaping (Result<[T], ChatError>) -> Void) -> ChatListener {
        let listener = reference.addSnapshotListener(includeMetadataChanges: false) { (snapshot, error) in
            if let snapshot = snapshot {
                let list: [T] = snapshot.documents.compactMap {
                    do {
                        return try $0.data(as: T.self)
                    } catch {
                        return nil
                    }
                }
                completion(.success(list))
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
