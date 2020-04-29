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

    // dedicated thread queue
    private let networkingQueue = DispatchQueue(label: "com.strv.chat.networking.firestore", qos: .background)

    public required init(config: ChatNetworkingFirestoreConfig, userManager: UserManagerFirestore) {

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
        self.userManager = userManager
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
        networkingQueue.async { [weak self] in
            self?.currentUserId = id
        }
    }
}

// MARK: - Load
public extension ChatNetworkingFirestore {
    func load(completion: @escaping (Result<Void, ChatError>) -> Void) {
        completion(.success(()))
    }
}

// MARK: Update conversation
public extension ChatNetworkingFirestore {
    func updateSeenMessage(_ message: MessageFirestore, in conversation: ConversationFirestore) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            var conversation = conversation
            conversation.setSeenMessages((messageId: message.id, seenAt: Date()), currentUserId: self.currentUserId)

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

    private func updateLastMessage(message: [String: Any]?, in conversation: EntityIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void) {
        let reference = self.database
            .collection(Constants.conversationsPath)
            .document(conversation)

        reference.updateData([Constants.Conversation.lastMessageAttributeName: message ?? FieldValue.delete]) { error in
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

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.prepareMessageData(message: message) { result in
                guard case let .success(data) = result else {
                    if case let .failure(error) = result {
                        print("Error while preparing message data \(error)")
                        completion(.failure(error))
                    }

                    return
                }

                self.storeMessage(in: conversation, messageData: data) { result in
                    guard case let .success(messageReference) = result else {
                        if case let .failure(error) = result {
                            print("Error while storing message \(error)")
                            completion(.failure(error))
                        }

                        return
                    }

                    self.updateLastMessage(message: data, in: conversation) { result in
                        guard case .success = result else {
                            if case let .failure(error) = result {
                                print("Error while setting conversation last message \(error)")
                                completion(.failure(error))
                            }

                            return
                        }

                        self.message(messageReference: messageReference, completion: completion)
                    }
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

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            let document = self.database
                .collection(Constants.conversationsPath)
                .document(conversation)
                .collection(Constants.messagesPath)
                .document(message.id)

            document.delete { error in
                if let error = error {
                    completion(.failure(.networking(error: error)))
                } else {

                    self.lastMessage(from: conversation, completion: { result in

                        guard case let .success(message) = result else {
                            if case let .failure(error) = result {
                                print("Error while loading last message \(error)")
                                completion(.failure(error))
                            }

                            return
                        }

                        self.updateLastMessage(message: message, in: conversation, completion: completion)
                    })
                }
            }
        }
    }

    private func lastMessage(from conversation: EntityIdentifier, completion: @escaping (Result<[String: Any]?, ChatError>) -> Void) {
        
        let lastMessageQuery = messagesQuery(conversation: conversation, numberOfMessages: 1)
        
        lastMessageQuery.getDocuments { (snapshot, error) in
            if let error = error {
                return completion(.failure(.networking(error: error)))
            } else {
                // conversation can be empty
                if let messageData = snapshot?.documents.first {
                    completion(.success(messageData.data()))
                } else {
                    completion(.success(nil))
                }
            }
        }
    }
}

// MARK: Listen to collections
public extension ChatNetworkingFirestore {
    func listenToConversations(pageSize: Int, completion: @escaping (Result<[ConversationFirestore], ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let listener = Listener.conversations(pageSize: pageSize)

            self.conversationsPagination = Pagination(
                updateBlock: completion,
                listener: listener,
                pageSize: pageSize
            )

            let query = self.conversationsQuery(numberOfConversations: self.conversationsPagination.itemsLoaded)

            self.listenTo(query: query, listener: listener, completion: { (result: Result<[ConversationFirestore], ChatError>) in

                guard case let .success(conversations) = result else {
                    print(result)
                    completion(result)
                    return
                }

                self.loadUsersForConversations(conversations: conversations, completion: completion)
            })
        }
    }

    func listenToMessages(conversation id: EntityIdentifier, pageSize: Int, completion: @escaping (Result<[MessageFirestore], ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let completion = self.reversedDataCompletion(completion: completion)
            let listener = Listener.messages(pageSize: pageSize, conversationId: id)
            let query = self.messagesQuery(conversation: id, numberOfMessages: pageSize)

            self.listenTo(query: query, listener: listener, completion: completion)

            self.messagesPaginators[id] = Pagination(
                updateBlock: completion,
                listener: listener,
                pageSize: pageSize
            )
        }
    }

    func remove(listener: Listener) {
        networkingQueue.async { [weak self] in
            self?.listeners[listener]?.remove()
        }
    }
    
    func loadMoreConversations() {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.conversationsPagination = self.advancePaginator(
                paginator: self.conversationsPagination,
                query: self.conversationsQuery(),
                listenerCompletion: { [weak self] result in
                    guard let self = self else {
                        return
                    }

                    guard let completion = self.conversationsPagination.updateBlock else {
                        print("Unexpected error, conversation pagination \(self.conversationsPagination) update block is nil")
                        return
                    }

                    switch result {
                    case .success(let conversations):
                        self.loadUsersForConversations(conversations: conversations, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
            })
        }
    }
    
    func loadMoreMessages(conversation id: String) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            guard let paginator = self.messagesPaginators[id] else {
                return
            }

            let query = self.messagesQuery(
                conversation: id,
                numberOfMessages: paginator.itemsLoaded
            )

            self.messagesPaginators[id] = self.advancePaginator(
                paginator: paginator,
                query: query,
                listenerCompletion: { (result: Result<[MessageFirestore], ChatError>) in
                    self.messagesPaginators[id]?.updateBlock?(result)
            })
        }
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
        let networkListener = query.addSnapshotListener(includeMetadataChanges: false) { [weak self] (snapshot, error) in
            self?.networkingQueue.async {
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
        self.userManager.users(userIds: conversations.flatMap { $0.memberIds }) { [weak self] result in
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

// MARK: - ChatNetworkingWithTypingUsers
extension ChatNetworkingFirestore: ChatNetworkingWithTypingUsers {
    public func setUserTyping(userId: EntityIdentifier, isTyping: Bool, in conversation: EntityIdentifier) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let document = self.database
                .collection(Constants.conversationsPath)
                .document(conversation)
                .collection(Constants.typingUsersPath)
                .document(userId)

            isTyping ? self.setTypingUser(typingUserReference: document) : self.removeTypingUser(typingUserReference: document)
        }
    }

    private func setTypingUser(typingUserReference: DocumentReference) {
        typingUserReference.setData([:]) { error in
            if let err = error {
                print("Error updating document: \(err)")
            } else {
                print("Typing user successfully set")
            }
        }
    }

    private func removeTypingUser(typingUserReference: DocumentReference) {
        typingUserReference.delete { error in
            if let err = error {
                print("Error deleting document: \(err)")
            } else {
                print("Typing user successfully removed")
            }
        }
    }

    public func listenToTypingUsers(in conversation: EntityIdentifier, completion: @escaping (Result<[UserFirestore], ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let query = self.database
                .collection(Constants.conversationsPath)
                .document(conversation)
                .collection(Constants.typingUsersPath)

            let listener = Listener.typingUsers(conversationId: conversation)
            // to infer type from generic
            let listenToCompletion: (Result<[EntityIdentifier], ChatError>) -> Void = { result in

                switch result {
                case .success(let userIds):
                    // Set members from previously downloaded users
                    self.userManager.users(userIds: userIds, completion: completion)
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
            }

            self.listenTo(query: query, listener: listener, completion: listenToCompletion)
        }
    }
}
