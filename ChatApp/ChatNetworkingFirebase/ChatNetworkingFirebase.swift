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
        let userId: String

        public init(configUrl: String, userId: String) {
            self.userId = userId
            self.configUrl = configUrl
        }
    }
    
    let database: Firestore

    public private(set) var currentUser: UserFirestore?

    private var listeners: [ChatListener: ListenerRegistration] = [:]
    private var initialized = false
    private var onLoadListeners: [(Result<Void, ChatError>) -> Void] = []
    private var currentUserId: String?
    private var users: [UserFirestore] = [] {
        didSet {
            if let currentUserId = currentUserId {
                currentUser = users.first{ $0.id == currentUserId }
            }
        }
    }

    required public init(config: Configuration) {
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }

        currentUserId = config.userId
        FirebaseApp.configure(options: options)
        
        self.database = Firestore.firestore()
        
        // FIXME: Remove this temporary code when UI for conversation creating is ready
        NotificationCenter.default.addObserver(self, selector: #selector(createTestConversation), name: NSNotification.Name(rawValue: "TestConversation"), object: nil)
        
        load { [weak self] result in
            self?.onLoadFinished(result: result)
        }
    }
    
    deinit {
        listeners.forEach { (listener, _) in
            remove(listener: listener)
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
        listenToUsers { [weak self] (result: Result<[UserFirestore], ChatError>) in
            switch result {
            case let .success(users):
                self?.users = users
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.networking(error: error)))
            }
        }
    }
    
    func onLoadFinished(result: (Result<Void, ChatError>)) {
        if case .success = result {
            initialized = true
        }
        
        onLoadListeners.forEach { $0(result) }
    }
}

// MARK: Write data
public extension ChatNetworkFirebase {
    func send(message: MessageSpecificationFirestore, to conversation: ChatIdentifier, completion: @escaping (Result<MessageFirestore, ChatError>) -> Void) {
        guard let currentUserId = self.currentUser?.id else {
            completion(.failure(.internal(message: "User not found")))
            return
        }

        message.toJSON { [weak self] result in
            guard let self = self, case let .success(json) = result else {
                if case let .failure(error) = result {
                    completion(.failure(error))
                }
                
                return
            }

            var newJSON: [String : Any] = json
            newJSON[Constants.Message.senderIdAttributeName] = currentUserId
            newJSON[Constants.Message.sentAtAttributeName] = Timestamp()

            let reference = self.database
                    .collection(Constants.conversationsPath)
                    .document(conversation)
                    .collection(Constants.messagesPath)

            let documentRef = reference.document()

            documentRef.setData(newJSON) { error in
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
       
        let listener = ChatListener.generateIdentifier()
        
        // FIXME: Make conversations path more generic
        let reference = database.collection(Constants.conversationsPath)
        
        let closureToRun = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.listenTo(reference: reference, customListener: listener, completion: { (result: Result<[ConversationFirestore], ChatError>) in
                
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
        
        if initialized {
            closureToRun()
        } else {
            onLoadListeners.append { result in
                switch result {
                case .success(()):
                    closureToRun()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return listener
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
    
    @discardableResult
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
    @discardableResult
    func listenTo<T: Decodable>(reference: Query, customListener: ChatListener? = nil, completion: @escaping (Result<[T], ChatError>) -> Void) -> ChatListener {
        let listener = reference.addSnapshotListener(includeMetadataChanges: false) { (snapshot, error) in
            if let snapshot = snapshot {
                let list: [T] = snapshot.documents.compactMap {
                    do {
                        return try $0.data(as: T.self)
                    } catch {
                        print("Couldn't decode document:", error)
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
        
        let identifier = customListener ?? ChatListener.generateIdentifier()
        
        listeners[identifier] = listener
        
        return identifier
    }
}
