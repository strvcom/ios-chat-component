//
//  ChatFirestore.swift
//  ChatFirestore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseCore
import FirebaseFirestore

open class ChatFirestore<Models: ChatFirestoreModeling>: ChatNetworkServicing {
    public typealias NetworkModels = Models
    public typealias UserManager = ChatFirestoreUserManager<UserFirestore>
    
    public typealias ConversationFirestore = Models.NetworkConversation
    public typealias MessageFirestore = Models.NetworkMessage
    public typealias UserFirestore = Models.NetworkUser
    public typealias MessageSpecificationFirestore = Models.NetworkMessageSpecification
    
    private let config: ChatFirestoreConfig
    private var constants: ChatFirestoreConstants {
        config.constants
    }

    // user management
    @Required private var currentUserId: String

    private let database: Firestore
    private let userManager: ChatFirestoreUserManager<UserFirestore>
    private let mediaUploader: MediaUploading

    private var listeners: [Listener: ListenerRegistration] = [:]
    private var messagesPaginators: [EntityIdentifier: Pagination<MessageFirestore>] = [:]
    private var conversationsPagination: Pagination<ConversationFirestore> = .empty

    public required init(config: ChatFirestoreConfig, userManager: UserManager, mediaUploader: MediaUploading = ChatFirestoreMediaUploader()) {

        // setup from config
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }

        let appName = UUID().uuidString
        FirebaseApp.configure(name: appName, options: options)
        guard let firebaseApp = FirebaseApp.app(name: appName) else {
            fatalError("Can't configure Firebase app \(appName)")
        }

        self.config = config
        self.database = Firestore.firestore(app: firebaseApp)
        self.userManager = userManager
        self.mediaUploader = mediaUploader
    }
    
    public convenience init(config: ChatFirestoreConfig, mediaUploader: MediaUploading = ChatFirestoreMediaUploader()) {
        let userManager = ChatFirestoreDefaultUserManager<UserFirestore>(config: config)
        
        self.init(config: config, userManager: userManager, mediaUploader: mediaUploader)
    }
    
    deinit {
        print("\(self) released")
        listeners.forEach {
            remove(listener: $0.key)
        }
    }
}

// MARK: - User management
public extension ChatFirestore {
    func setCurrentUser(user id: EntityIdentifier) {
        currentUserId = id
    }
}

// MARK: - Load
public extension ChatFirestore {
    func load(completion: @escaping (Result<Void, ChatError>) -> Void) {
        completion(.success(()))
    }
}

// MARK: Update conversation
public extension ChatFirestore {
    func updateSeenMessage(_ message: MessageFirestore, in conversation: ConversationFirestore) {
        var json: [String: Any] = conversation.seen.mapValues({
            [constants.conversations.seenAttribute.messageIdAttributeName: $0.messageId,
            constants.conversations.seenAttribute.timestampAttributeName: $0.seenAt]
        })
        
        json[currentUserId] = [
            constants.conversations.seenAttribute.messageIdAttributeName: message.id,
            constants.conversations.seenAttribute.timestampAttributeName: Timestamp()
        ]
        
        let reference = self.database
            .collection(constants.conversations.path)
            .document(conversation.id)

        reference.updateData([constants.conversations.seenAttribute.name: json]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    private func updateLastMessage(message: [String: Any]?, in conversation: EntityIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void) {
        let reference = self.database
            .collection(constants.conversations.path)
            .document(conversation)

        reference.updateData([constants.conversations.lastMessageAttributeName: message ?? FieldValue.delete]) { error in
            if let error = error {
                completion(.failure(.networking(error: error)))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: Create message
public extension ChatFirestore {
    func send(message: MessageSpecificationFirestore, to conversation: EntityIdentifier, completion: @escaping (Result<MessageFirestore, ChatError>) -> Void) {

        prepareMessageData(message: message) { [weak self] result in
            guard let self = self, case let .success(data) = result else {
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

    private func storeMessage(in conversation: EntityIdentifier, messageData: [String: Any], completion: @escaping (Result<DocumentReference, ChatError>) -> Void) {
        let reference = self.database
            .collection(constants.conversations.path)
            .document(conversation)
            .collection(constants.messages.path)

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
    
    private func uploadMedia(for json: ChatJSON, completion: @escaping (Result<ChatJSON, ChatError>) -> Void) {
        var normalizedJSON: ChatJSON = [:]
        var resultError: ChatError?
        
        let dispatchGroup = DispatchGroup()
        
        for (key, value) in json {
            switch value {
            case let value as MediaContent:
                dispatchGroup.enter()
                
                // TODO: Switch to dedicated queue
                mediaUploader.upload(content: value, on: .main) { result in
                    switch result {
                    case .success(let url):
                        normalizedJSON[key] = url
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
        
        // TODO: Switch to dedicated queue
        dispatchGroup.notify(queue: .main) {
            if let error = resultError {
                completion(.failure(error))
            } else {
                completion(.success(normalizedJSON))
            }
        }
    }

}

// MARK: - Delete message
public extension ChatFirestore {
    func delete(message: MessageFirestore, from conversation: EntityIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void) {
        let document = self.database
            .collection(constants.conversations.path)
            .document(conversation)
            .collection(constants.messages.path)
            .document(message.id)

        document.delete { [weak self] error in
            if let error = error {
                completion(.failure(.networking(error: error)))
            } else {

                self?.lastMessage(from: conversation, completion: { result in

                    guard case let .success(message) = result else {
                        if case let .failure(error) = result {
                            print("Error while loading last message \(error)")
                            completion(.failure(error))
                        }

                        return
                    }

                    self?.updateLastMessage(message: message, in: conversation, completion: completion)
                })
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
public extension ChatFirestore {
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
private extension ChatFirestore {
    func conversationsQuery(numberOfConversations: Int? = nil) -> Query {
        let query = database
            .collection(constants.conversations.path)
            .whereField(constants.conversations.membersAttributeName, arrayContains: currentUserId)

        if let limit = numberOfConversations {
            return query.limit(to: limit)
        }
        
        return query
    }
    
    func messagesQuery(conversation id: String, numberOfMessages: Int?) -> Query {
        let query = database
            .collection(constants.conversations.path)
            .document(id)
            .collection(constants.messages.path)
            .order(by: constants.messages.sentAtAttributeName, descending: true)
        
        if let limit = numberOfMessages {
            return query.limit(to: limit)
        }
        
        return query
    }
}

// MARK: Private methods
private extension ChatFirestore {
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
extension ChatFirestore: ChatNetworkingWithTypingUsers {
    public func setUserTyping(userId: EntityIdentifier, isTyping: Bool, in conversation: EntityIdentifier) {
        let document = self.database
            .collection(constants.conversations.path)
            .document(conversation)
            .collection(constants.typingUsers.path)
            .document(userId)

        isTyping ? setTypingUser(typingUserReference: document) : removeTypingUser(typingUserReference: document)
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

        let query = self.database
            .collection(constants.conversations.path)
            .document(conversation)
            .collection(constants.typingUsers.path)

        let listener = Listener.typingUsers(conversationId: conversation)
        // to infer type from generic
        let listenToCompletion: (Result<[EntityIdentifier], ChatError>) -> Void = { [weak self] result in

            guard let self = self else {
                return
            }

            switch result {
            case .success(let userIds):
                // Set members from previously downloaded users
                self.userManager.users(userIds: userIds, completion: completion)
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }

        listenTo(query: query, listener: listener, completion: listenToCompletion)
    }
}
