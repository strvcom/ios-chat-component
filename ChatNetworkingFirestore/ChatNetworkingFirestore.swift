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

    private var listeners: [Listener: ListenerRegistration] = [:]
    private var messagesPaginators: [EntityIdentifier: Pagination<MessageFirestore>] = [:]
    private var conversationsPagination: Pagination<ConversationFirestore> = .empty

    private let userManager: UserManagerFirestore

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
        userManager = UserManagerFirestore(database: database)
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
        completion(.success(()))
    }
}

// MARK: Write data
public extension ChatNetworkingFirestore {
    func send(message: MessageSpecificationFirestore, to conversation: EntityIdentifier, completion: @escaping (Result<MessageFirestore, ChatError>) -> Void) {

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
                            print("Message successfully sent")
                            completion(.success(message))
                        } else {
                            completion(.failure(.unexpectedState))
                        }
                    }
                }
            }
        }
    }

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
                print(result)
                completion(result)
                return
            }

            self.loadUsersForConversations(conversations: conversations, completion: completion)
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

    func remove(listener: Listener) {
        listeners[listener]?.remove()
    }
    
    func loadMoreConversations() {
        self.conversationsPagination = advancePaginator(
            paginator: conversationsPagination,
            query: conversationsQuery(),
            listenerCompletion: { [weak self] result in
                guard let self = self, let completion = self.conversationsPagination.updateBlock else {
                    return
                }

                switch result {
                case .success(let conversations):
                    self.loadUsersForConversations(conversations: conversations, completion: completion)
                    self.conversationsPagination.updateBlock?(.success(conversations))
                case .failure(let error):
                    completion(.failure(error))
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

    func conversationsWithMembers(conversations: [ConversationFirestore], users: [UserFirestore]) -> [ConversationFirestore] {
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

    func loadUsersForConversations(conversations: [ConversationFirestore], completion: @escaping (Result<[ConversationFirestore], ChatError>) -> Void) {
        let userIds = Array(Set(conversations.flatMap { $0.memberIds }))
        self.userManager.users(userIds: userIds) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let users):
                // Set members from previously downloaded users
                completion(.success(self.conversationsWithMembers(conversations: conversations, users: users)))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
}
