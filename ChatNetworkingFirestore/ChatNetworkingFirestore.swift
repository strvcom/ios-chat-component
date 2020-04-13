//
//  ChatNetworkingFirebase.swift
//  ChatNetworkingFirebase
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseFirestore
import FirebaseCore

public class ChatNetworkingFirestore: ChatNetworkServicing {
    let database: Firestore

    // user management
    @Required private var currentUserId: String
    private var users: [UserFirestore] = []
    
    private var listeners: [Listener: ListenerRegistration] = [:]
    private var messagesPaginators: [EntityIdentifier: Pagination<MessageFirestore>] = [:]
    private var conversationsPagination: Pagination<ConversationFirestore> = .empty

    public required init(config: ChatNetworkingFirestoreConfig) {

        // setup from config
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }
        let appName = UUID().uuidString
        FirebaseApp.configure(name: appName, options: options)
        guard let firebaseApp = FirebaseApp.app(name: appName) else {
            fatalError("Can't configure Firebase app \(appName)")
        }
        database = Firestore.firestore(app: firebaseApp)

    }
    
    deinit {
        print("\(self) released")
        listeners.forEach {
            remove(listener: $0.key)
        }
    }
}

// MARK: - User management
public extension ChatNetworkingFirestore {
    func setCurrentUser(user id: EntityIdentifier) {
        currentUserId = id
    }
}

// MARK: - Load
public extension ChatNetworkingFirestore {
    func load(completion: @escaping (Result<Void, ChatError>) -> Void) {
        listenToUsers { [weak self] (result: Result<[UserFirestore], ChatError>) in
            switch result {
            case let .success(users):
                self?.users = users
                completion(.success(()))
            case let .failure(error):
                print(error)
                completion(.failure(.networking(error: error)))
            }
        }
    }
}

// MARK: Update conversation
public extension ChatNetworkingFirestore {
    func updateSeenMessage(_ message: MessageFirestore, in conversation: ConversationFirestore) {

        var conversation = conversation
        conversation.setSeenMessages((messageId: message.id, seenAt: Date()), currentUserId: currentUserId)

        var newJson: [String: Any] = [:]

        for item in conversation.seen {
            let informationJson: [String: Any] = [Constants.Message.messageIdAttributeName: item.value.messageId,
                                                  Constants.Message.timestampAttributeName: item.value.seenAt]
            newJson[item.key] = informationJson
        }

        let reference = self.database
            .collection(Constants.conversationsPath)
            .document(conversation.id)

        reference.updateData([Constants.Conversation.seenAttributeName: newJson]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    private func updateLastMessage(message: [String: Any], in conversation: EntityIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void) {
        let reference = self.database
            .collection(Constants.conversationsPath)
            .document(conversation)

        reference.setData([Constants.Conversation.lastMessageAttributeName: message], merge: true) { error in
            if let error = error {
                completion(.failure(.networking(error: error)))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: Create message
public extension ChatNetworkingFirestore {
    func send(message: MessageSpecificationFirestore, to conversation: EntityIdentifier, completion: @escaping (Result<MessageFirestore, ChatError>) -> Void) {

        prepareMessageData(message: message) { [weak self] result in
            guard let self = self, case let .success(data) = result else {
                if case let .failure(error) = result {
                    print("Message 1successfully sent")
                    completion(.failure(error))
                }

                return
            }

            self.storeMessage(in: conversation, messageData: data) { result in
                guard case let .success(messageReference) = result else {
                    if case let .failure(error) = result {
                        print("Message2 successfully sent")
                        completion(.failure(error))
                    }

                    return
                }

                self.updateLastMessage(message: data, in: conversation) { result in
                    guard case .success = result else {
                        if case let .failure(error) = result {
                            print("Message3 successfully sent")
                            completion(.failure(error))
                        }

                        return
                    }

                    self.message(messageReference: messageReference, completion: completion)
                }
            }
        }
    }

    private func prepareMessageData(message: MessageSpecificationFirestore, completion: @escaping (Result<[String: Any], ChatError>) -> Void) {
        message.toJSON { [weak self] result in
            guard let self = self, case let .success(json) = result else {
                if case let .failure(error) = result {
                    completion(.failure(error))
                }

                return
            }

            var newJSON: [String: Any] = json
            newJSON[Constants.Message.senderIdAttributeName] = self.currentUserId
            newJSON[Constants.Message.sentAtAttributeName] = Timestamp()
            completion(.success(newJSON))
        }
    }

    private func storeMessage(in conversation: EntityIdentifier, messageData: [String: Any], completion: @escaping (Result<DocumentReference, ChatError>) -> Void) {
        let reference = self.database
            .collection(Constants.conversationsPath)
            .document(conversation)
            .collection(Constants.messagesPath)

        let documentRef = reference.document()
        documentRef.setData(messageData) { error in
            if let error = error {
                completion(.failure(.networking(error: error)))
            } else {
                completion(.success(documentRef))
            }
        }
    }

    private func message(messageReference: DocumentReference, completion: @escaping (Result<MessageFirestore, ChatError>) -> Void) {
        messageReference.getDocument { (documentSnapshot, error) in
            if let error = error {
                completion(.failure(.networking(error: error)))
            } else if let message = try? documentSnapshot?.data(as: MessageFirestore.self) {
                print("Message successfully sent")
                completion(.success(message))
            } else {
                completion(.failure(.unexpectedState))
            }
        }
    }
}

// MARK: - Delete message
public extension ChatNetworkingFirestore {
    func delete(message: MessageFirestore, from conversation: EntityIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void) {
        let document = self.database
            .collection(Constants.conversationsPath)
            .document(conversation)
            .collection(Constants.messagesPath)
            .document(message.id)
        document.delete { error in
            if let error = error {
                completion(.failure(.networking(error: error)))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: Listen to collections
public extension ChatNetworkingFirestore {
    func listenToConversations(pageSize: Int, completion: @escaping (Result<[ConversationFirestore], ChatError>) -> Void) {
        
        let listener = Listener.conversations(pageSize: pageSize)
        
        conversationsPagination = Pagination(
            updateBlock: completion,
            listener: listener,
            pageSize: pageSize
        )
        
        let query = conversationsQuery(numberOfConversations: conversationsPagination.itemsLoaded)
        
        listenTo(query: query, listener: listener, completion: { [weak self] (result: Result<[ConversationFirestore], ChatError>) in
            
            guard let self = self else {
                return
            }
            
            guard case let .success(conversations) = result else {
                completion(result)
                return
            }

            // Set members from previously downloaded users
            completion(.success(self.conversationsWithMembers(conversations: conversations)))
        })
    }

    func listenToMessages(conversation id: EntityIdentifier, pageSize: Int, completion: @escaping (Result<[MessageFirestore], ChatError>) -> Void) {
        
        let completion = reversedDataCompletion(completion: completion)
        let listener = Listener.messages(pageSize: pageSize, conversationId: id)
        let query = messagesQuery(conversation: id, numberOfMessages: pageSize)
        
        listenTo(query: query, listener: listener, completion: completion)
        
        messagesPaginators[id] = Pagination(
            updateBlock: completion,
            listener: listener,
            pageSize: pageSize
        )
    }
    
    func listenToUsers(completion: @escaping (Result<[UserFirestore], ChatError>) -> Void) {
        let query = database.collection(Constants.usersPath)
        listenTo(query: query, listener: .users, completion: completion)
    }
    
    func remove(listener: Listener) {
        listeners[listener]?.remove()
    }
    
    func loadMoreConversations() {
        self.conversationsPagination = advancePaginator(
            paginator: conversationsPagination,
            query: conversationsQuery(),
            listenerCompletion: { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let conversations):
                    self.conversationsPagination.updateBlock?(.success(self.conversationsWithMembers(conversations: conversations)))
                case .failure(let error):
                    self.conversationsPagination.updateBlock?(.failure(error))
                }
        })
    }
    
    func loadMoreMessages(conversation id: String) {
        
        guard let paginator = messagesPaginators[id] else {
            return
        }
        
        let query = messagesQuery(
            conversation: id,
            numberOfMessages: paginator.itemsLoaded
        )
        
        messagesPaginators[id] = advancePaginator(
            paginator: paginator,
            query: query,
            listenerCompletion: { [weak self] (result: Result<[MessageFirestore], ChatError>) in
                self?.messagesPaginators[id]?.updateBlock?(result)
        })
    }
}

// MARK: Queries
private extension ChatNetworkingFirestore {
    func conversationsQuery(numberOfConversations: Int? = nil) -> Query {
        let query = database
            .collection(Constants.conversationsPath)
            .whereField(Constants.Message.membersAttributeName, arrayContains: currentUserId)

        if let limit = numberOfConversations {
            return query.limit(to: limit)
        }
        
        return query
    }
    
    func messagesQuery(conversation id: String, numberOfMessages: Int?) -> Query {
        let query = database
            .collection(Constants.conversationsPath)
            .document(id)
            .collection(Constants.messagesPath)
            .order(by: Constants.Message.sentAtAttributeName, descending: true)
        
        if let limit = numberOfMessages {
            return query.limit(to: limit)
        }
        
        return query
    }
}

// MARK: Private methods
private extension ChatNetworkingFirestore {
    func listenTo<T: Decodable>(query: Query, listener: Listener, completion: @escaping (Result<[T], ChatError>) -> Void) {
        let networkListener = query.addSnapshotListener(includeMetadataChanges: false) { (snapshot, error) in
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
        
        listeners[listener] = networkListener
    }
    
    func conversationsWithMembers(conversations: [ConversationFirestore]) -> [ConversationFirestore] {
        conversations.map { conversation in
            var result = conversation
            result.setMembers(users.filter { result.memberIds.contains($0.id) })
            return result
        }
    }
    
    func advancePaginator<T: Decodable>(paginator: Pagination<T>, query: Query, listenerCompletion: @escaping (Result<[T], ChatError>) -> Void) -> Pagination<T> {
        
        var paginator = paginator
        
        remove(listener: paginator.listener)
        
        paginator.nextPage()
        
        let query = query.limit(to: paginator.itemsLoaded)
        
        listenTo(query: query, listener: paginator.listener, completion: listenerCompletion)
        
        return paginator
    }
    
    func reversedDataCompletion<T: Decodable>(completion: @escaping (Result<[T], ChatError>) -> Void) -> (Result<[T], ChatError>) -> Void {
        return { result in
            switch result {
            case .success(let data):
                completion(.success(data.reversed()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
