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
import FirebaseStorage

/// Implementation of `ChatNetworkServicing` for Firestore backends
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
    private let decoder: JSONDecoder

    // user management
    @Required private var currentUserId: String

    private let database: Firestore
    private let userManager: ChatFirestoreUserManager<UserFirestore>
    private let mediaUploader: MediaUploading

    private var listeners: [Listener: ListenerRegistration] = [:]
    private var messagesPaginators: [EntityIdentifier: Pagination<MessageFirestore>] = [:]
    private var conversationsPagination: Pagination<ConversationFirestore> = .empty

    // dedicated thread queue
    private let networkingQueue = DispatchQueue(label: "com.strv.chat.networking.firestore", qos: .userInteractive)

    public required init(config: ChatFirestoreConfig, userManager: UserManager, mediaUploader: MediaUploading = ChatFirestoreMediaUploader(), decoder: JSONDecoder = JSONDecoder()) {

        // setup from config
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }

        let appName = UUID().uuidString
        FirebaseApp.configure(name: appName, options: options)
        guard let firebaseApp = FirebaseApp.app(name: appName) else {
            fatalError("Can't configure Firebase app \(appName)")
        }
        
        // Pass firebase app reference to `ChatFirestoreMediaUploader`
        if let uploader = mediaUploader as? ChatFirestoreMediaUploader {
            uploader.firebaseApp = firebaseApp
        }

        self.config = config
        self.decoder = decoder
        self.database = Firestore.firestore(app: firebaseApp)
        self.userManager = userManager
        self.mediaUploader = mediaUploader
    }
    
    public convenience init(config: ChatFirestoreConfig, mediaUploader: MediaUploading = ChatFirestoreMediaUploader(), decoder: JSONDecoder = JSONDecoder()) {
        let userManager = ChatFirestoreDefaultUserManager<UserFirestore>(config: config, decoder: decoder)
        
        self.init(config: config, userManager: userManager, mediaUploader: mediaUploader, decoder: decoder)
    }
    
    deinit {
        print("\(self) released")
        listeners.forEach {
            stop(listener: $0.key)
        }
    }
}

// MARK: - User management
public extension ChatFirestore {
    func setCurrentUser(user id: EntityIdentifier) {
        networkingQueue.async { [weak self] in
            self?.currentUserId = id
        }
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

// MARK: Create message
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
                    data[Constants.identifierAttributeName] = referenceMessage.documentID
                    transaction.updateData([self.constants.conversations.lastMessageAttributeName: data], forDocument: referenceConversation)

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

// MARK: Listen to collections
public extension ChatFirestore {
    func listenToConversation(conversation id: EntityIdentifier, completion: @escaping (Result<ConversationFirestore, ChatError>) -> Void) {
        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            let listener = Listener.conversation(conversationId: id)
            let reference = self.database
                .collection(self.constants.conversations.path)
                .document(id)

            self.listenToDocument(reference: reference, listener: listener, completion: { (result: Result<ConversationFirestore, ChatError>) in
                
                guard case let .success(conversation) = result else {
                    completion(result)
                    return
                }

                self.loadUsersForConversations(conversations: [conversation]) { result in
                    switch result {
                    case .success(let conversations):
                        if let conversation = conversations.first {
                            completion(.success(conversation))
                        } else {
                            completion(.failure(.unexpectedState))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            })
        }
    }

    func listenToConversations(pageSize: Int, completion: @escaping (Result<[ConversationFirestore], ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let listener = Listener.conversationList(pageSize: pageSize)

            self.conversationsPagination = Pagination(
                updateBlock: completion,
                listener: listener,
                pageSize: pageSize
            )

            let query = self.conversationsQuery(numberOfConversations: self.conversationsPagination.itemsLoaded)

            self.listenToCollection(query: query, listener: listener, completion: { (result: Result<[ConversationFirestore], ChatError>) in

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

            self.listenToCollection(query: query, listener: listener, completion: completion)

            self.messagesPaginators[id] = Pagination(
                updateBlock: completion,
                listener: listener,
                pageSize: pageSize
            )
        }
    }

    func remove(listener: Listener) {
        networkingQueue.async { [weak self] in
            self?.stop(listener: listener)
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
    func listenToCollection<T: Decodable>(query: Query, listener: Listener, completion: @escaping (Result<[T], ChatError>) -> Void) {
        let networkListener = query.addSnapshotListener(includeMetadataChanges: false) { [weak self, decoder] (snapshot, error) in
            self?.networkingQueue.async {
                if let snapshot = snapshot {
                    let list: [T] = snapshot.documents.compactMap {
                        do {
                            return try $0.decode(to: T.self, with: decoder)
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
    
    func stop(listener: Listener) {
        listeners[listener]?.remove()
        listeners[listener] = nil
    }

    func listenToDocument<T: Decodable>(reference: DocumentReference, listener: Listener, completion: @escaping (Result<T, ChatError>) -> Void) {
        let networkListener = reference.addSnapshotListener { [weak self, decoder] (snapshot, error) in
            self?.networkingQueue.async {
                if let snapshot = snapshot {
                    do {
                        let object = try snapshot.decode(to: T.self, with: decoder)
                        completion(.success(object))
                    } catch {
                        completion(.failure(.internal(message: "Couldn't decode document: \(error)")))
                    }
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
            result.members = users.filter { result.memberIds.contains($0.id) }
            return result
        }
    }

    func advancePaginator<T: Decodable>(paginator: Pagination<T>, query: Query, listenerCompletion: @escaping (Result<[T], ChatError>) -> Void) -> Pagination<T> {
        
        var paginator = paginator
        
        stop(listener: paginator.listener)
        
        paginator.nextPage()
        
        let query = query.limit(to: paginator.itemsLoaded)
        
        listenToCollection(query: query, listener: paginator.listener, completion: listenerCompletion)
        
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
            self.networkingQueue.async {
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
}

// MARK: - ChatNetworkingWithTypingUsers
extension ChatFirestore: ChatNetworkingWithTypingUsers {
    public func setUserTyping(userId: EntityIdentifier, isTyping: Bool, in conversation: EntityIdentifier) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let document = self.database
                .collection(self.constants.conversations.path)
                .document(conversation)
                .collection(self.constants.typingUsers.path)
                .document(userId)

            isTyping ? self.setTypingUser(typingUserReference: document) : self.removeTypingUser(typingUserReference: document)
        }
    }

    private func setTypingUser(typingUserReference: DocumentReference) {
        typingUserReference.setData([:]) { error in
            if let err = error {
                print("Error updating user typing: \(err)")
            } else {
                print("Typing user successfully set")
            }
        }
    }

    private func removeTypingUser(typingUserReference: DocumentReference) {
        typingUserReference.delete { error in
            if let err = error {
                print("Error deleting user typing: \(err)")
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
                .collection(self.constants.conversations.path)
                .document(conversation)
                .collection(self.constants.typingUsers.path)

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

            self.listenToCollection(query: query, listener: listener, completion: listenToCompletion)
        }
    }
}
